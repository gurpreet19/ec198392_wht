#!perl
####################################################################################################################################################################################
#
# Version history 
#
# Version   Date         Who                  Comments
# --------  -----------  -------------------  ------------------------------------------------------------------------------------------------------------------------
#      1.0  2017-10-27   Arjan Schuiten       Intial version
#      1.1  2017-11-01   Arjan Schuiten       Including new functionality
#                                             - NEVER_STOP_ON_ERROR
#                                             - make SIMULATE_QUERY / DELETE_GEN_FILES / NEVER_STOP_ON_ERROR configurable from OPERATION_PARAMETERS file
#                                             - introduction of phases that can be executed
#                                             - analyze the headless tool logging for FATAL and ERROR messages
#                                             - ignore errors in the logging when they are on the ignore list
#      1.2  2017-11-03   Arjan Schuiten       Fixing issues
#                                             - changing directory back to main directory again after headless upgrade tool execution
#                                             - make each phase stop on a error by switching stop_on_error from 0 to 1
#                                             Including new functionality
#                                             - include checking database health before and after upgrade
#      1.3  2017-11-04   Arjan Schuiten       Fixing issues
#                                             - changing sequence of views and packages for class model upgrade (first views then packages)
#      1.4  2017-11-07   Arjan Schuiten       Including new functionality
#                                             - include creating missing grants
#                                             - include creating missing synonyms
#                                             - sqlloader log also in default format
#                                             - when password is left blanc in operation_parameter file, then prompt user for password
#      1.5  2017-11-15   Arjan Schuiten       Fixing issues
#                                             - remove set define off from scripts, this will prevent parameters being passed on
#
#                                             *********************** FOR FUTURE VERSION ***********************
#                                             - include make valid script 
#                                             - stop_on_string needs to be more strict
#                                             - migration report also into log dir
#                                             - make password user input hidden when typing
#                                             - include mail functionality on error / warning / info
#                                             - move sub procedure to libraries instead of in the main script
#      1.6  2017-12-08   Arjan Schuiten       Fixing issues
#                                             - always include a commit at the end of a generated SQL file
#      1.7  2017-12-14   Arjan Schuiten       New functionality
#                                             - First parameter is the mode that needs to be executed
#                                               + null or 1 will run the upgrade
#                                               + 2 will run the ST scripts
#                                               + 3 will run the UAT scripts
#                                             - Time difference between start and end of the script
#                                             - Included ignore error string to prevent throwing an error where it's not an error
#                                             - Show reason of error in case of database connection error
#                                             Fixing issues
#                                             - Show correct end status in NON SIMULATED mode
#      1.8  2017-12-22   Arjan Schuiten       New functionality
#                                             - First delete directory .workspace in headless tool directory before starting headless tool
#      1.9  2017-12-29   Arjan Schuiten       New functionality
#                                             - Include sending email after completion of the script
#      2.0  2018-01-17   Arjan Schuiten       New functionality
#                                             - Include duration in the message subject
#                                             - Include status of log analyze in SendMail for:
#                                               + HEADLESS TOOL
#                                               + missing grants 
#                                               + missing synonyms
#      2.1  2018-01-19   Arjan Schuiten       New functionality
#                                             - make headless tool version configuration driven
#                                               + add the following line to your operation.parameters.sql: define headlesstool='headless-3.0.0-SNAPSHOT'
#                                             - included the missing grant script in the code instead of being dependend on the database package
#
####################################################################################################################################################################################
use strict;
use DBI;
use Try::Tiny;
use Cwd;

use lib '_Perl/lib_custom';
use Functions;
use Files;
use File::Copy;

####################################################################################################################################################################################
### Inital values, which can be adjusted
####################################################################################################################################################################################

our $DEBUG               = 0;
our $LOG_TO_FILE         = 1;
our $LOG_TO_CONSOLE      = 1;
my  $SIMULATE_QUERY      = 0;
my  $DELETE_GEN_FILES    = 0;
my  $NEVER_STOP_ON_ERROR = 0;
my  $CTL_DIR             = "configuration/03_01_UCMT/ctl";
my  $DATA_DIR            = "configuration/03_01_UCMT/class_versions";

# Provide a string |-seperated with the strings that should result in an error situation
# For example 'ora-|sp2-|error'
my $stop_on_string      = 'ora-|sp2-|error';
my $stop_on_string_ign  = 'Raise_Application_Error';

####################################################################################################################################################################################
### Inital values, which can NOT be adjusted
####################################################################################################################################################################################

my @adjusted_parameters;
my @phases;
my $mode;
   $mode = 'Upgrade'              if( $ARGV[0] == 1 || $ARGV[0] eq '' );

foreach(split(/,/, $ARGV[1])) {
	my $id = int($_);
	$phases[$id] = 1;
}
@phases = (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1) if($ARGV[1] eq '');

my  $prefix             = (Functions->GetDateString('yyyymmddhhmiss'));
mkdir "logging/$prefix";
mkdir "generated_scripts/$prefix";
my  $main_dir           = getcwd;
our $LOG_FILE           = "$main_dir/logging/$prefix/_Upgrade.log";
my  $operation_param    = "$main_dir/configuration/operation_parameters.sql";
my  $global_status      = 'SUCCES';

####################################################################################################################################################################################
### Main process
####################################################################################################################################################################################
my $global_start    = Functions->GetDateString('yyyymmddhhmiss');
Functions->LogAction('I', "Process started");
Functions->LogAction('I', "Start reading configuration from [ $operation_param ]");
my @parameters      = Files->ReadFileToArray($operation_param);
my $p               = 0;
while($p <= $#parameters) {
	if($parameters[$p] =~ /^\w{0,}define/) {
		$parameters[$p]  =~ s/^\w{0,}define //g;
		my @values       = split(/=/,$parameters[$p]);
		$values[1]       = $1 if($values[1] =~ /'(.*)'/ ne '');
		$ENV{$values[0]} = $values[1];
		Functions->LogAction('D', "*** Parameter [ $values[0] ] with value [ $values[1] ] found");
	}
	$p++;
}
$global_status   = 'SIMULATED' if($ENV{'SIMULATE_QUERY'});
@parameters      = Files->ReadFileToArray($operation_param);
&requestPassword('ec_schema_password'     , 'ECKERNEL'      ) if($ENV{'ec_schema_password'}      eq '');
&requestPassword('ec_energyx_password'    , 'ENERGYX'       ) if($ENV{'ec_energyx_password'}     eq '');
&requestPassword('ec_transfer_password'   , 'TRANSFER'      ) if($ENV{'ec_transfer_password'}    eq '');
&requestPassword('ec_reporting_password'  , 'REPORTING'     ) if($ENV{'ec_reporting_password'}   eq '');
printf("\n") if($#adjusted_parameters > -1);

$SIMULATE_QUERY      = $ENV{'SIMULATE_QUERY'}      if($ENV{'SIMULATE_QUERY'}      ne '');
$DELETE_GEN_FILES    = $ENV{'DELETE_GEN_FILES'}    if($ENV{'DELETE_GEN_FILES'}    ne '');
$NEVER_STOP_ON_ERROR = $ENV{'NEVER_STOP_ON_ERROR'} if($ENV{'NEVER_STOP_ON_ERROR'} ne '');
$ENV{'headlesstool'} = 'headless-4.0.0'   		if($ENV{'headlesstool'}        eq '');

$ENV{'database_name_headless'} = '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST='.$ENV{'db_hostname'}.')(PORT='.$ENV{db_port}.'))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME='.$ENV{db_service_name}.')))';


my $connect_string   = 'ECKERNEL_'.$ENV{'operation'}.'/"'.$ENV{'ec_schema_password'}.'"@'.$ENV{'database_name'};
Functions->LogAction('D', "*** Parameter [ connect_string ] with value [ $connect_string ] found");
Functions->LogAction('I', "Done reading configuration");
Functions->LogAction('I', "==================================================================================================");
Functions->LogAction('I', " Initial settings ");
Functions->LogAction('I', "==================================================================================================");
Functions->LogAction('I', "");
Functions->LogAction('I', "Mode                 = [ $mode ]");
Functions->LogAction('I', "Phases               = [ $ARGV[1] ]") if($ARGV[1] ne '');
Functions->LogAction('I', "Dircetory            = [ $main_dir ]");
Functions->LogAction('I', "Parameter file       = [ $operation_param ]");
Functions->LogAction('I', "NLS_LANG             = [ $ENV{'NLS_LANG'} ]");
Functions->LogAction('I', "Database connection  = [ $ENV{'database_name'} ]");
Functions->LogAction('I', "Database connection headless = [ $ENV{'database_name_headless'} ]");																							   
Functions->LogAction('I', "Operation            = [ $ENV{'operation'} ]");
Functions->LogAction('I', "Environment          = [ $ENV{'environment'} ]");
Functions->LogAction('I', "Delta release used   = [ $ENV{'DELTA_FOLDER_NAME'} ]");
Functions->LogAction('I', "Upgrade from         = [ $ENV{'version_from'} ]");
Functions->LogAction('I', "Upgrade to           = [ $ENV{'version_to'} ]");
Functions->LogAction('I', "");
my $value = 'No ';
   $value = 'Yes' if($ENV{'SIMULATE_QUERY'} == 1);
Functions->LogAction('I', "Simulate query       = [ $value ]");
   $value = 'No ';
   $value = 'Yes' if($ENV{'DELETE_GEN_FILES'} == 1);   
Functions->LogAction('I', "Delete files         = [ $value ]");
   $value = 'No ';
   $value = 'Yes' if($ENV{'NEVER_STOP_ON_ERROR'} == 1);   
Functions->LogAction('I', "Never stop on error  = [ $value ]");
Functions->LogAction('I', "");
Functions->LogAction('I', "==================================================================================================");
Functions->LogAction('I', " Test database connections ");
Functions->LogAction('I', "==================================================================================================");
Functions->LogAction('I', "");
&testDbConnection($ENV{'database_name'}, 'ECKERNEL_' .$ENV{'operation'}    , $ENV{'ec_schema_password'}     );
&testDbConnection($ENV{'database_name'}, 'ENERGYX_'  .$ENV{'operation'}    , $ENV{'ec_energyx_password'}    );
&testDbConnection($ENV{'database_name'}, 'TRANSFER_' .$ENV{'operation'}    , $ENV{'ec_transfer_password'}   );
&testDbConnection($ENV{'database_name'}, 'REPORTING_'.$ENV{'operation'}    , $ENV{'ec_reporting_password'}  );
Functions->LogAction('I', "");
&testDbHealth($ENV{'database_name'}, 'ECKERNEL_' .$ENV{'operation'}, $ENV{'ec_schema_password'}   );
	#Functions->LogAction('I', "==================================================================================================");
	#Functions->LogAction('I', " 00. Precheck step ");
	#Functions->LogAction('I', "==================================================================================================");
	#Functions->LogAction('I', "");
	#&executeSqlScriptsInFolder($connect_string, '00_Precheck', 1);
	#Functions->LogAction('I', "");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', " 01. Running global pre upgrade scripts ");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', "");
	&executeSqlScriptsInFolder($connect_string, '01_Global_Pre_Upgrade_Scripts', 1)                                                                                          if( $phases[1]);
	Functions->LogAction('W', "This part of the script is skipped")                                                                                                          if(!$phases[1]);
	Functions->LogAction('I', "");                                                                                                                                           
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', " 02. Running project pre upgrade scripts ");                                                                                                  
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', "");                                                                                                                                           
	&executeSqlScriptsInFolder($connect_string, '02_Project_Pre_Upgrade_Scripts', 1)                                                                                         if( $phases[2]);
	Functions->LogAction('W', "This part of the script is skipped")                                                                                                          if(!$phases[2]);
	Functions->LogAction('I', "");                                                                                                                                           
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', " 03.01.01. Upgrade class model ");                                                                                                            
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', "");                                                                                                                                           
	&executeSqlScriptsInFolder($connect_string, '03_Delta_Upgrade/01_UCMT/01_Scripts', 1)                                                                                    if( $phases[3]);
	Functions->LogAction('W', "This part of the script is skipped")                                                                                                          if(!$phases[3]);
	Functions->LogAction('I', "");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', " 03.01.02. Load class configuration data for new version [ $ENV{'version_to'} ]");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', "");
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_to'}/class_cnfg.csv"                 , "$CTL_DIR/load_new_class_cnfg.ctl"               ,1, '03_01_02_01') if( $phases[4]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_to'}/class_property_cnfg.csv"        , "$CTL_DIR/load_new_class_property_cnfg.ctl"      ,1, '03_01_02_02') if( $phases[4]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_to'}/class_dependency_cnfg.csv"      , "$CTL_DIR/load_new_class_dependency_cnfg.ctl"    ,1, '03_01_02_03') if( $phases[4]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_to'}/class_trigger_actn_cnfg.csv"    , "$CTL_DIR/load_new_class_trigger_actn_cnfg.ctl"  ,1, '03_01_02_04') if( $phases[4]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_to'}/class_tra_property_cnfg.csv"    , "$CTL_DIR/load_new_class_tra_property_cnfg.ctl"  ,1, '03_01_02_05') if( $phases[4]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_to'}/class_attribute_cnfg.csv"       , "$CTL_DIR/load_new_class_attribute_cnfg.ctl"     ,1, '03_01_02_06') if( $phases[4]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_to'}/class_attr_property_cnfg.csv"   , "$CTL_DIR/load_new_class_attr_property_cnfg.ctl" ,1, '03_01_02_07') if( $phases[4]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_to'}/class_relation_cnfg.csv"        , "$CTL_DIR/load_new_class_relation_cnfg.ctl"      ,1, '03_01_02_08') if( $phases[4]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_to'}/class_rel_property_cnfg.csv"    , "$CTL_DIR/load_new_class_rel_property_cnfg.ctl"  ,1, '03_01_02_09') if( $phases[4]);
	Functions->LogAction('W', "This part of the script is skipped")                                                                                                          if(!$phases[4]);
	Functions->LogAction('I', "");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', " 03.01.03. Load class configuration data for old version [ $ENV{'version_from'} ]");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', "");
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_from'}/class_property_cnfg.csv"      , "$CTL_DIR/load_prev_class_property_cnfg.ctl"     ,1, '03_01_03_01') if( $phases[5]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_from'}/class_cnfg.csv"               , "$CTL_DIR/load_prev_class_cnfg.ctl"              ,1, '03_01_03_02') if( $phases[5]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_from'}/class_dependency_cnfg.csv"    , "$CTL_DIR/load_prev_class_dependency_cnfg.ctl"   ,1, '03_01_03_03') if( $phases[5]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_from'}/class_trigger_actn_cnfg.csv"  , "$CTL_DIR/load_prev_class_trigger_actn_cnfg.ctl" ,1, '03_01_03_04') if( $phases[5]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_from'}/class_tra_property_cnfg.csv"  , "$CTL_DIR/load_prev_class_tra_property_cnfg.ctl" ,1, '03_01_03_05') if( $phases[5]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_from'}/class_attribute_cnfg.csv"     , "$CTL_DIR/load_prev_class_attribute_cnfg.ctl"    ,1, '03_01_03_06') if( $phases[5]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_from'}/class_attr_property_cnfg.csv" , "$CTL_DIR/load_prev_class_attr_property_cnfg.ctl",1, '03_01_03_07') if( $phases[5]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_from'}/class_relation_cnfg.csv"      , "$CTL_DIR/load_prev_class_relation_cnfg.ctl"     ,1, '03_01_03_08') if( $phases[5]);
	&executeSqlLdrScript($connect_string,"$DATA_DIR/$ENV{'version_from'}/class_rel_property_cnfg.csv"  , "$CTL_DIR/load_prev_class_rel_property_cnfg.ctl" ,1, '03_01_03_09') if( $phases[5]);
	Functions->LogAction('W', "This part of the script is skipped")                                                                                                          if(!$phases[5]);
	Functions->LogAction('I', "");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', " 03.01.04. Apply new class model to system ");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', "");
	&executeSqlScriptsInFolder($connect_string, '03_Delta_Upgrade/01_UCMT/02_Scripts' , 1)                                                                                   if( $phases[6]);
	&executeSqlScriptsInFolder($connect_string, '03_Delta_Upgrade/01_UCMT/03_AddOn'   , 1)                                                                                   if( $phases[6]);
	&executeSqlScriptsInFolder($connect_string, '03_Delta_Upgrade/01_UCMT/04_Views'   , 1)                                                                                   if( $phases[6]);
	&executeSqlScriptsInFolder($connect_string, '03_Delta_Upgrade/01_UCMT/05_Packages', 1)                                                                                   if( $phases[6]);
	&executeSqlScriptsInFolder($connect_string, '03_Delta_Upgrade/01_UCMT/06_Cleanup' , 1)                                                                                   if( $phases[6]);
	Functions->LogAction('W', "This part of the script is skipped")                                                                                                          if(!$phases[6]);
	Functions->LogAction('I', "");                                                                                                                                           
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', " 03.02. Run headless upgrade tool ");                                                                                                         
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', "");                                                                                                                                           
	&executeHeadlessTool()                                                                                                                                                   if( $phases[7] && !$SIMULATE_QUERY);
	Functions->LogAction('W', "This part of the script is skipped")                                                                                                          if(!$phases[7]);
	Functions->LogAction('I', "");                                                                                                                                           
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', " 04. Running global post upgrade scripts ");                                                                                                  
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', "");                                                                                                                                           
	&executeSqlScriptsInFolder($connect_string, '04_Global_Post_Upgrade_Scripts', 1)                                                                                         if( $phases[8]);
	Functions->LogAction('W', "This part of the script is skipped")                                                                                                          if(!$phases[8]);
	Functions->LogAction('I', "");                                                                                                                                           
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', " 05. Running project post upgrade scripts ");                                                                                                 
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', "");                                                                                                                                           
	&executeSqlScriptsInFolder($connect_string, '05_Project_Post_Upgrade_Scripts', 1)                                                                                        if( $phases[9]);
	Functions->LogAction('W', "This part of the script is skipped")                                                                                                          if(!$phases[9]);
	Functions->LogAction('I', "");
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', " 07. Running Reconfiguration scripts ");                                                                                                 
	Functions->LogAction('I', "==================================================================================================");                                         
	Functions->LogAction('I', "");                                                                                                                                           
	&executeSqlScriptsInFolder($connect_string, '07_Reconfig', 1)                                                                                        					 if( $phases[10]);
	Functions->LogAction('W', "This part of the script is skipped")                                                                                                          if(!$phases[10]);
	Functions->LogAction('I', "");
	&testDbHealth         ($ENV{'database_name'}, 'ECKERNEL_'  .$ENV{'operation'}, $ENV{'ec_schema_password'}    );
	&createMissingGrants  ($ENV{'database_name'}, 'ECKERNEL_'  .$ENV{'operation'}, $ENV{'ec_schema_password'}    );
	&createMissingSynonyms($ENV{'database_name'}, 'ENERGYX_'   .$ENV{'operation'}, $ENV{'ec_energyx_password'}   );
	&createMissingSynonyms($ENV{'database_name'}, 'TRANSFER_'  .$ENV{'operation'}, $ENV{'ec_transfer_password'}  );
	&createMissingSynonyms($ENV{'database_name'}, 'REPORTING_' .$ENV{'operation'}, $ENV{'ec_reporting_password'} );


if($DELETE_GEN_FILES) {
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', " Clean up generated files ");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', "");
	my @files = &getFileList("generated_scripts/$prefix", '\.sql$|');
	foreach(@files) {
		my $file        = $_;
		&deleteFile("$file");
	}
	Functions->LogAction('I', "");
}
Functions->LogAction('I', "==================================================================================================");
my $global_finish   = Functions->GetDateString('yyyymmddhhmiss');
my $global_duration = Functions->DiffDateStrings($global_start, $global_finish);
Functions->LogAction('I', "Process finished with [ $global_status ] [ $global_duration ]");
&resetParameterFile() if($#adjusted_parameters > -1);
&sendMail();

####################################################################################################################################################################################
### Functions used in the main script
####################################################################################################################################################################################

sub testDbConnection {
	my ($db_connect_string, $db_usr, $db_pwd) = @_;
	my $result;
	my $dbh;

	try {
		my $conn   = "dbi:Oracle:";
		   $conn  .= "$db_connect_string";

		$dbh       = DBI->connect($conn, $db_usr, $db_pwd, { PrintError => 0,
															 PrintWarn  => 1,
															 RaiseError => 1,
														   });
		my $stmt   = "ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS'";
		my $sth    = $dbh->prepare( $stmt );
		my $rv     = $sth->execute();
		$stmt      = "ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '. '";
		$sth       = $dbh->prepare( $stmt );
		$rv        = $sth->execute();
	}
	catch {
		my $error = $_;
		if( $error =~ /failed: (.*) \(DBD ERROR/ ne '') {
			$error = $1;
		}
		
		Functions->LogAction('E', "Unable to connect to database [ $db_connect_string ] with user [ $db_usr ]");
		Functions->LogAction('E', "With error [ $error ]");
		&exitWithError;
	};	
	Functions->LogAction('I', "Connected to database [ $db_connect_string ] with user [ $db_usr ]");
	$dbh->disconnect if defined($dbh);

	return 1;
}

sub getFileList {
    my ($path, $extensions) = @_;
	my @FileList;
	
    opendir (DIR, $path) or die "Unable to open $path: $!";
    my @files = grep { !/^\.{1,2}$/ } readdir (DIR);
    closedir (DIR);
    @files = map { $path . '/' . $_ } @files;

    for (@files) {
        if (-d $_) {
            my @SubFileList = getFileList($_);
			push(@FileList, @SubFileList);
        } 
		else { 
			push(@FileList, $_) if(lc($_) =~ /$extensions/);
        }
    }
	return @FileList;
}

sub deleteFile {
	my ($file) = @_;
	Functions->LogAction('I', "Deleting file  [ $file ]");
	unlink($file) or die "File delete failed: $!" ;
}

sub executeSqlScript {
	my($connect_string, $script, $stop_on_error) = @_;
	my $start       = Functions->GetDateString('yyyymmddhhmiss');
	Functions->LogAction('I', "Start executing script [ $script ]");
	Functions->LogAction('I', "");
	
	my $status         = 'SUCCES';
	my $result         = `sqlplus -s $connect_string \@$script  2>&1`;
	my @result         = split(/\n/, $result);

	my $r = 0;
	Functions->LogAction('I', "With script output:") if($#result >= 0);
	Functions->LogAction('I', "--------------------------------------------------------------------------------------------------") if($#result >= 0);
	while($r <= $#result) {
		Functions->LogAction('I', "**** $result[$r]");
		$status = 'ERROR'   if($result[$r] =~ /$stop_on_string/i && !($result[$r] =~ /$stop_on_string_ign/i) &&    $stop_on_error && !$NEVER_STOP_ON_ERROR );
		$status = 'WARNING' if($result[$r] =~ /$stop_on_string/i && !($result[$r] =~ /$stop_on_string_ign/i) && ( !$stop_on_error ||  $NEVER_STOP_ON_ERROR ) && $status ne 'ERROR' );
		$r++;
	}
	Functions->LogAction('I', "--------------------------------------------------------------------------------------------------") if($#result >= 0);
    my @file_detail = split(/\//, $script);
	my @file_name   = split(/\./, $file_detail[$#file_detail]);
	Files->Write("logging/$prefix/$file_name[0].log", $result) ;

	Functions->LogAction('I', "");
	my $finish      = Functions->GetDateString('yyyymmddhhmiss');
	my $duration    = Functions->DiffDateStrings($start, $finish);
	Functions->LogAction('I', "Done executing script  [ $script ] with [ $status ] [ $duration ]");
	if ($status eq 'WARNING') {
		Functions->LogAction('W', "Script execution contains error(s) but was executed with continue in case of error(s)");
		$global_status = 'WARNING';
	}
	elsif ($status eq 'ERROR') {	
		Functions->LogAction('E', "Script has error(s) and was executed with stop in case of error(s), so stopping the main process");
		&exitWithError;
	}
	Functions->LogAction('I', "");

	return 1;
}

sub executeSqlLdrScript {
	my($connect_string, $data, $control, $stop_on_error, $step_name) = @_;
	my $start       = Functions->GetDateString('yyyymmddhhmiss');
	Functions->LogAction('I', "Start executing sqlldr for data [ $data ]");
	
	$step_name        .= '_' if($step_name =~ // ne '' && $step_name =~ /\_$/ eq '');
	my $status         = 'SUCCES';
	   $status         = 'SIMULATED' if($SIMULATE_QUERY);
    my @file_detail    = split(/\//, $control);
	my @file_name      = split(/\./, $file_detail[$#file_detail]);
	my $log            = "logging/$prefix/$step_name$file_name[0].log";
	my $bad            = "logging/$prefix/$step_name$file_name[0].bad";
	my $discard        = "logging/$prefix/$step_name$file_name[0].dsc"; 
	my $result;
	$result            = `sqlldr userid=$connect_string control=$control log=$log bad=$bad discard=$discard data=$data  2>&1` if(!$SIMULATE_QUERY);
	my @result         = split(/\n/, $result);

	my $r = 0;
	if($#result >= 0) {
	  Functions->LogAction('I', "");
	  Functions->LogAction('I', "With script output:");
	  Functions->LogAction('I', "--------------------------------------------------------------------------------------------------");
	}
	
	@result = Files->ReadFileToArray($log) if(!$SIMULATE_QUERY);
	while($r <= $#result) {
		Functions->LogAction('I', "**** $result[$r]");
		if($result[$r] =~ /(\d{0,}) Rows{0,1} not loaded/) {
			my $errors = $1;
			$status = 'ERROR'   if($errors > 0 &&    $stop_on_error && !$NEVER_STOP_ON_ERROR  );
			$status = 'WARNING' if($errors > 0 && ( !$stop_on_error ||  $NEVER_STOP_ON_ERROR ) && $status ne 'ERROR' );
		}
		$r++;
	}
	Functions->LogAction('I', "--------------------------------------------------------------------------------------------------") if($#result >= 0);
	my $finish      = Functions->GetDateString('yyyymmddhhmiss');
	my $duration    = Functions->DiffDateStrings($start, $finish);
	Functions->LogAction('I', "Done  executing sqlldr for data [ $data ] with [ $status ] [ $duration ]");
	if ($status eq 'WARNING') {
		Functions->LogAction('W', "Sqlldr execution contains error(s) but was executed with continue in case of error(s)");
		$global_status = 'WARNING';
	}
	elsif ($status eq 'ERROR') {	
		Functions->LogAction('E', "Sqlldr has error(s) and was executed with stop in case of error(s), so stopping the main process");
		&exitWithError;
	}
	Functions->LogAction('I', "");

	return 1;
}

sub executeSqlScriptsInFolder {
  my ( $connect_string, $folder_name, $stop_on_error, $additional ) = @_;
	my @files = &getFileList($folder_name, '\.sql$');
	foreach(@files) {
		my $file     = $_;
		my $gen_file;
		my $first_part;
		my $last_part;
		my @subs     = split(/\//,$file);
		foreach(@subs) {
			my @parts   =  split(/_/,$_);
			$first_part =  $parts[0];
			$last_part  =  join( "_", @parts); 
			$last_part  =~ s/^$parts[0]_//g; 
			$gen_file  .=  $first_part."_";
		}
		my $file_to_write = "generated_scripts/$prefix/$gen_file$last_part";
		my $file_content  = Files->ReadFileToString($file);
		$file_content     =~ s/(set\s{1,}define\s{1,}off)/--\1/gi;
		Files->Write($file_to_write,'set long 9999','>');
		Files->Write($file_to_write,'set heading off');
		Files->Write($file_to_write,'set verify off');
		Files->Write($file_to_write,'set feedback off');
		Files->Write($file_to_write,'set echo off');
		Files->Write($file_to_write,'set pagesize 9999');
		Files->Write($file_to_write,'set linesize 220');
		Files->Write($file_to_write,'set trimspool on');
		Files->Write($file_to_write,'set serveroutput on');
		Files->Write($file_to_write,'set tab off');
		Files->Write($file_to_write,'');
		Files->Write($file_to_write,'@"'.$operation_param.'"')  if( $additional == 1 || $additional eq '');
		Files->Write($file_to_write,'');
		Files->Write($file_to_write,'---------- START OF SCRIPT ----------');
		Files->Write($file_to_write,'');
		Files->Write($file_to_write,$file_content);
		Files->Write($file_to_write,'');
		Files->Write($file_to_write,'----------  END OF SCRIPT  ----------');
		Files->Write($file_to_write,'');
		Files->Write($file_to_write,'commit;')                  if( $additional == 1 || $additional eq '');
		Files->Write($file_to_write,'');
		Files->Write($file_to_write,'set define on');
		Files->Write($file_to_write,'set heading on');
		Files->Write($file_to_write,'set verify on');
		Files->Write($file_to_write,'set feedback on');
		Files->Write($file_to_write,'set serveroutput off');
		Files->Write($file_to_write,'exit');
		Functions->LogAction('I', "SQL script generated   [ $file_to_write ]");
		
		&executeSqlScript($connect_string, $file_to_write, $stop_on_error) if(!$SIMULATE_QUERY);
	}
}

sub generateHeadlessConfig {
	my ($target_dir) = @_;
	my $tempstring = $main_dir;
	$tempstring    =~ s/\//\\\\/g;
	Functions->LogAction('I', "Generating headless upgrade tool configuration based on the operation_parameters.sql");
	Files->Write("$target_dir/deploymentConfig.properties","#-------------AUTOGENERATED------------", '>');
	Files->Write("$target_dir/deploymentConfig.properties","TARGET_DB_USER=ECKERNEL_$ENV{'operation'}");
	Files->Write("$target_dir/deploymentConfig.properties","TARGET_DB_URL=$ENV{'database_name_headless'}");
	Files->Write("$target_dir/deploymentConfig.properties","TARGET_DB_PASSWORD=$ENV{'ec_schema_password'}");
	Files->Write("$target_dir/deploymentConfig.properties","DELTA_PATH=$tempstring\\\\configuration\\\\03_02_headless_tool\\\\");
	Files->Write("$target_dir/deploymentConfig.properties","DELTA_FOLDER_NAME=$ENV{'DELTA_FOLDER_NAME'}");
	Files->Write("$target_dir/deploymentConfig.properties","ENERGYX_PASSWORD=$ENV{'ec_energyx_password'}");
	Files->Write("$target_dir/deploymentConfig.properties","REPORTING_PASSWORD=$ENV{'ec_reporting_password'}");
	Files->Write("$target_dir/deploymentConfig.properties","TRANSFER_PASSWORD=$ENV{'ec_transfer_password'}");
	Files->Write("$target_dir/deploymentConfig.properties","MODE=UPGRADE_MODE");
	Functions->LogAction('I', "Configration generated [ $target_dir/deploymentConfig.properties ]");
}

sub copyHeadlessConfig {
	my ($source_dir, $target_dir) = @_;
	Functions->LogAction('I', "Copying configuration for headless upgrade tool");
	Functions->LogAction('I', "From [ $source_dir ] to [ $target_dir ]");

 	my @files = &getFileList($source_dir, '\.properties$\.upg$|');
	foreach(@files) {
		my $file        = $_;
		my @file_detail = split(/\//, $file);
		Functions->LogAction('I', "Copying file [ $file_detail[$#file_detail] ]");
		copy($file,"$target_dir/") or die "Copy failed: $!";
	}
	Functions->LogAction('I', "Copying done");
	Functions->LogAction('I', "");
}

sub deleteHeadlessConfig {
	my ($target_dir, $based_on) = @_;
	Functions->LogAction('I', "Deleting configuration for headless upgrade tool");
	Functions->LogAction('I', "Based on files [ $based_on ]");

 	my @files = &getFileList($based_on, '\.properties$\.upg$|');
	foreach(@files) {
		my $file        = $_;
		my @file_detail = split(/\//, $file);
		&deleteFile("$target_dir/$file_detail[$#file_detail]");
	}
	Functions->LogAction('I', "Deleting configuration done");
}

sub executeHeadlessTool {
	my $command_to_execute  = 'java';
       $command_to_execute .= ' -Xms4096m';
	   $command_to_execute .= ' -Xmx8192M';
	   $command_to_execute .= ' -XX:+UseParallelGC';
	   $command_to_execute .= ' -XX:+HeapDumpOnOutOfMemoryError';
	   $command_to_execute .= ' -XX:PermSize=256M';
	   $command_to_execute .= ' -XX:MaxPermSize=512M';
	   $command_to_execute .= ' -Duser.timezone=UTC';
	   $command_to_execute .= ' -jar '.$ENV{'headlesstool'}.'.jar';
	my $start       = Functions->GetDateString('yyyymmddhhmiss');

	Functions->LogAction('D', "Command to execute [ $command_to_execute ]");
    &generateHeadlessConfig("configuration/03_02_headless_tool/config");
    Functions->LogAction('I', "");
    &copyHeadlessConfig("configuration/03_02_headless_tool/config", "03_Delta_Upgrade/02_Headless_Upgrade_Tool");
    chdir("$main_dir/03_Delta_Upgrade/02_Headless_Upgrade_Tool");
	if (-e ".workspace" and -d ".workspace") {
		Functions->LogAction('W', "Found directory [ .workspace ] so first cleaning up");
		&deldir('.workspace');
	}

	my $status         = 'SUCCES';
	Functions->LogAction('I', "*********** START RUNNING HEADLESS UPGRADE TOOL ***********");
	my $result         = `$command_to_execute  2>&1`;
	Functions->LogAction('I', "*********** DONE  RUNNING HEADLESS UPGRADE TOOL ***********");
	Functions->LogAction('I', "");
	my @result         = split(/\n/, $result);

#	if($#result >= 0) {
#		Functions->LogAction('I', "With console output:");
#		Functions->LogAction('I', "--------------------------------------------------------------------------------------------------");
#		my $r = 0;
#		while($r <= $#result) {
#			if($result[$r] =~ /FileLogger\.java/ eq '' && $result[$r] =~ /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/ ne '') {
#				Functions->LogAction('I', "**** $result[$r]");
#				$status = 'ERROR'   if($result[$r] =~ /$stop_on_string/i && !$NEVER_STOP_ON_ERROR );
#				$status = 'WARNING' if($result[$r] =~ /$stop_on_string/i &&  $NEVER_STOP_ON_ERROR && $status ne 'ERROR' );
#			}
#			$r++;
#		}
#		Functions->LogAction('I', "--------------------------------------------------------------------------------------------------");
#	}
	
	my @log_files = getFileList("$main_dir/03_Delta_Upgrade/02_Headless_Upgrade_Tool/log/",'\.log$');
	&analyzeLogHeadlessTool($log_files[$#log_files]);

	Functions->LogAction('I', "");
	my $finish      = Functions->GetDateString('yyyymmddhhmiss');
	my $duration    = Functions->DiffDateStrings($start, $finish);
	Functions->LogAction('I', "Done executing headless upgrade tool with [ $status ] [ $duration ]");

	if(-d "$main_dir/03_Delta_Upgrade/02_Headless_Upgrade_Tool/log/") {
		foreach(getFileList("$main_dir/03_Delta_Upgrade/02_Headless_Upgrade_Tool/log/","log")){
		  move($_,"$main_dir/logging/$prefix/.");
		}
	}
	
    chdir("$main_dir");

	if ($status eq 'WARNING') {
		Functions->LogAction('W', "Headless upgrade tool execution contains error(s) but was executed with continue in case of error(s)");
		$global_status = 'WARNING';
	}
	elsif ($status eq 'ERROR') {	
		Functions->LogAction('E', "Headless upgrade tool has error(s) and was executed with stop in case of error(s), so stopping the main process");
		&exitWithError;
	}

	return 1;
}

sub analyzeLogHeadlessTool {
	my ($file) = @_;
	my $start       = Functions->GetDateString('yyyymmddhhmiss');
	Functions->LogAction('I', "");

	my @file_parts     = split(/\//, $file);
	my @file_name      = split(/\./, $file_parts[$#file_parts]);
	my $file_to_write  = "$main_dir/logging/$prefix/".$file_name[0]."_errors.log";
	Functions->LogAction('I', "Start analyzing for FATAL and ERROR in log file [ $file_parts[$#file_parts] ] ");
	Functions->LogAction('I', "");

	my $ERRORS_FOUND   = 0;
	my $ERRORS_IGNORED = 0;
	my $FATALS_FOUND   = 0;
	my $FATALS_IGNORED = 0;
	my $status         = 'SUCCES';

	my @result;
       @result         = Files->ReadFileToArray($file) if( -f $file );
	my $ignore_file    = "$main_dir/configuration/03_02_headless_tool/config/errors.ignore";
	my @ignore_list;
       @ignore_list    = Files->ReadFileToArray($ignore_file) if( -f $ignore_file );

	if($#result >= 0) {
		Functions->LogAction('I', "Found issues in log file:");
		Functions->LogAction('I', "--------------------------------------------------------------------------------------------------");
		my $r = 0;
		while($r <= $#result) {
			if($result[$r] =~ /- FATAL -|- ERROR -/ ne '') {
				my $error = $result[$r];
				   $error =~ s/.*- FATAL - //g;
				   $error =~ s/.*- ERROR - //g;
				my $i     = 0;
				my $found = 0;

				while($i <= $#ignore_list && !$found) {
					if($error =~ /$ignore_list[$i]/ ne '') {
						$found = 1;
					}
					$i++;
				}

				if($found) {
					Functions->LogAction('I', "**** IGNORED - ".substr($error,0,150));
					Files->Write($file_to_write, "IGNORE - $result[$r]");
					$FATALS_IGNORED++ if($result[$r] =~ /- FATAL -/ ne '');
					$ERRORS_IGNORED++ if($result[$r] =~ /- ERROR -/ ne '');
				} 
				else {
					Functions->LogAction('E', "**** ".substr($error,0,150));
					$status = 'ERROR'   if($result[$r] =~ /- FATAL -|- ERROR -/i && !$NEVER_STOP_ON_ERROR );
					$status = 'WARNING' if($result[$r] =~ /- FATAL -|- ERROR -/i &&  $NEVER_STOP_ON_ERROR && $status ne 'ERROR' );
					Files->Write($file_to_write, "ERROR  - $result[$r]");
					$FATALS_FOUND++ if($result[$r] =~ /- FATAL -/ ne '');
					$ERRORS_FOUND++ if($result[$r] =~ /- ERROR -/ ne '');
				}
			}
			$r++;
		}
		Functions->LogAction('I', "--------------------------------------------------------------------------------------------------");
	}

	Functions->LogAction('I', "");
	Functions->LogAction('I', "Errors found and ignored : $ERRORS_IGNORED");
	Functions->LogAction('I', "Fatals found and ignored : $FATALS_IGNORED");
	Functions->LogAction('I', "------------------------------------------");
	Functions->LogAction('I', "Totals ignored           : ".($FATALS_IGNORED+$ERRORS_IGNORED));
	Functions->LogAction('I', "");
	Functions->LogAction('I', "Errors found             : $ERRORS_FOUND");
	Functions->LogAction('I', "Fatals found             : $FATALS_FOUND");
	Functions->LogAction('I', "------------------------------------------");
	Functions->LogAction('I', "Totals not ignored       : ".($FATALS_FOUND+$ERRORS_FOUND));
	Functions->LogAction('I', "");
	my $finish      = Functions->GetDateString('yyyymmddhhmiss');
	my $duration    = Functions->DiffDateStrings($start, $finish);
	Functions->LogAction('I', "Done analyzing for FATAL and ERROR in log file [ $file_parts[$#file_parts] ] with [ $status ] [ $duration ]");

	if ($status eq 'WARNING') {
		Functions->LogAction('W', "Log file headless upgrade tool contains error(s) but was executed with continue in case of error(s)");
		$global_status = 'WARNING';
	}
	elsif ($status eq 'ERROR') {	
		Functions->LogAction('E', "Log file headless upgrade tool contains error(s) and was executed with stop in case of error(s), so stopping the main process");
		&exitWithError;
	}

	return 1;
}

sub testDbHealth {
	my ($db_connect_string, $db_usr, $db_pwd) = @_;

	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', " Report on issues at database object level (invalid objects / disabled triggers, constraints)");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', "");
	
	my $result;
	my $dbh;

	my $conn   = "dbi:Oracle:";
	   $conn  .= "$db_connect_string";

	$dbh       = DBI->connect($conn, $db_usr, $db_pwd, { PrintError => 0,
														 PrintWarn  => 1,
														 RaiseError => 1,
													   });
	my $stmt;
	my $sth;
	my $rv;
	
    $stmt   = "select 'Invalid object '||object_type
               ,      count(1) rec_cnt 
               from   user_objects 
               where  status <> 'VALID' 
               group by object_type 
               union
               select 'Disabled '||decode(constraint_type, 'R', 'referential', 'P', 'primary', 'U', 'unique', 'C', 'check', 'other') || ' constraint ' constraint_type
               ,      count(1) rec_cnt 
               from   user_constraints 
               where  status <> 'ENABLED' 
               group by constraint_type
               union
               select 'Disabled trigger'
               ,      count(1) rec_cnt 
               from   user_triggers 
               where  status <> 'ENABLED' 
			   having count(1) > 0
               order by 1
              ";				   
	$sth    = $dbh->prepare( $stmt );
	$rv     = $sth->execute();

	my $notfound = 1;
	while(my @row = $sth->fetchrow_array()) {
		$notfound = 0;
		Functions->LogAction('I', Functions->rpad($row[0], ' ', 40).' : '.Functions->lpad($row[1], ' ', 7));
	}
	Functions->LogAction('I', "No invalid objects or disabled triggers or disabled constraints found") if($notfound);
	$dbh->disconnect if defined($dbh);

	Functions->LogAction('I', "");
	return 1;
}

sub createMissingGrants {
	my ($db_connect_string, $db_usr, $db_pwd) = @_;
	my $start       = Functions->GetDateString('yyyymmddhhmiss');
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', " Creating missing grants for schema [ $db_usr ]");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', "");
	my $status = 'SUCCES';
	my $dbh;

	my $conn   = "dbi:Oracle:";
	   $conn  .= "$db_connect_string";

	$dbh       = DBI->connect($conn, $db_usr, $db_pwd, { PrintError => 0,
														 PrintWarn  => 1,
														 RaiseError => 1,
													   });
	my $stmt;
	my $sth;
	my $rv;
	
	$stmt = "DECLARE
                lv2_operation  VARCHAR2(100) := '$ENV{'operation'}';   
                
				PROCEDURE AddMissingGrantsReadOnly(p_role_name IN VARCHAR2) is
				  CURSOR c_object_to_grant IS
                    select /*+ Rule */ 'GRANT SELECT ON ' || a.object_name || ' to ' || p_role_name  || chr(10) text
                    from user_objects a
                        left join user_tab_privs b on ( b.grantee = p_role_name
                                                        and b.table_name = a.object_name
                                                        and b.privilege = 'SELECT')
                    where a.object_type in ('VIEW','TABLE','SEQUENCE')
                    AND   b.grantee is null
                    UNION all
                    select /*+ Rule */ 'GRANT EXECUTE ON ' || a.object_name || ' to ' || p_role_name  || chr(10) text
                    from user_objects a
                        left join user_tab_privs b on ( b.grantee = p_role_name
                                                        and b.table_name = a.object_name
                                                        and b.privilege = 'EXECUTE')
                    where object_type in ('PACKAGE','PROCEDURE','FUNCTION','TYPE')
                    AND   b.grantee is null;
                
                  lv2_sql        VARCHAR2(2000);
                
                  lv2_errPrefix  VARCHAR2(100) := '-----Grant Stmt Error List:-----';
                  lv2_errorMsg   VARCHAR2(32767) := lv2_errPrefix;
                BEGIN
                  FOR cur_rec IN c_object_to_grant LOOP
                      lv2_sql := cur_rec.text;
                      BEGIN
                         EXECUTE IMMEDIATE lv2_sql;
                      EXCEPTION
                        WHEN OTHERS THEN
                          IF (length(lv2_errorMsg) + length(lv2_sql) + length(sqlerrm) + 100) < 32767 THEN
                            lv2_errorMsg := lv2_errorMsg || chr(10) || 'Grant stmt failed: [' || lv2_sql || ']. Error msg: [' || sqlerrm || ']';
                          END IF;
                      END;
                   END LOOP;
				   
                   IF length(lv2_errorMsg) > length(lv2_errPrefix) THEN
                     ecdp_dynsql.WriteTempText('GRANT_MISSING','Error when executing AddMissingGrantsReadOnly. The following statements failed:' || chr(10) || lv2_errorMsg);
                   END IF;
                END  AddMissingGrantsReadOnly;

                PROCEDURE AddMissingGrantsWrite(p_role_name IN VARCHAR2) is
                  CURSOR c_object_to_grant IS
                   select 'GRANT EXECUTE ON ' || a.object_name || ' To ' || p_role_name || chr(10) text
                   from user_objects a
                   left join user_tab_privs b on ( b.grantee =  p_role_name
                                                        and b.table_name = a.object_name
                                                        and b.privilege = 'EXECUTE')
                   where object_type in ('PACKAGE','PROCEDURE','FUNCTION','TYPE')
                   AND   b.grantee is null
                   UNION all
                   SELECT 'GRANT SELECT ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
                   from user_objects a
                        left join user_tab_privs b on ( b.grantee = p_role_name
                                                        and b.table_name = a.object_name
                                                        and b.privilege = 'SELECT')
                   where a.object_type in ('TABLE','SEQUENCE')
                   AND   b.grantee is null
                   UNION all
                   SELECT 'GRANT SELECT ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
                   from user_objects a
                        left join user_tab_privs b on ( b.grantee = p_role_name
                                                        and b.table_name = a.object_name
                                                        and b.privilege = 'SELECT')
                   where a.object_type = 'VIEW'
                   AND   b.grantee is null
                   AND   a.object_name not like '%JN'
                   UNION all
                   SELECT 'GRANT INSERT ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
                   from user_objects a
                        left join user_tab_privs b on ( b.grantee = p_role_name
                                                        and b.table_name = a.object_name
                                                        and b.privilege = 'INSERT')
                   where a.object_type in ('TABLE')
                   AND   b.grantee is null
                   UNION all
                   SELECT 'GRANT UPDATE ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
                   from user_objects a
                        left join user_tab_privs b on ( b.grantee = p_role_name
                                                        and b.table_name = a.object_name
                                                        and b.privilege = 'UPDATE')
                   where a.object_type in ('TABLE')
                   AND   b.grantee is null
                   UNION all
                   SELECT 'GRANT DELETE ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
                   from user_objects a
                        left join user_tab_privs b on ( b.grantee = p_role_name
                                                        and b.table_name = a.object_name
                                                        and b.privilege = 'DELETE')
                   where a.object_type in ('TABLE')
                   AND   b.grantee is null
                   UNION all
                   SELECT 'GRANT INSERT,UPDATE,DELETE ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
                   from user_objects a
                        left join user_tab_privs b on ( b.grantee = p_role_name
                                                        and b.table_name = a.object_name
                                                        and b.privilege = 'INSERT')
                        left join user_triggers ut on ( ut.table_name = a.object_name
                                                        and ut.trigger_type = 'INSTEAD OF'
                                                        and ut.table_owner = user )
                   where a.object_type in ('VIEW')
                   AND   not (a.object_name like '%JN')
                   AND   not (a.object_name like 'RV%')
                   AND   b.grantee is null
                   AND   ( ( not substr(a.object_name,1,2) in('DV','TV','IV') ) OR  (ut.trigger_name is not  null) )
                   AND   not a.object_name in ('DAO_CLASS_DEPENDENCY','DAO_META','DEFERMENT_GROUPS','GROUPS','OBJECTS','OBJECTS_VERSION')
                   and  not exists ( select 1 from class c where c.class_name = substr(a.object_name,4) and substr(a.object_name,1,3) in ('DV','TV','IV')  and c.read_only_ind = 'Y');
                
                  lv2_sql        VARCHAR2(2000);
                
                  lv2_errPrefix  VARCHAR2(100) := '-----Grant Stmt Error List:-----';
                  lv2_errorMsg   VARCHAR2(32767) := lv2_errPrefix;
                BEGIN
                  FOR cur_rec IN c_object_to_grant LOOP
                      lv2_sql := cur_rec.text;
                      BEGIN
                         EXECUTE IMMEDIATE lv2_sql;
                      EXCEPTION
                        WHEN OTHERS THEN
                          IF (length(lv2_errorMsg) + length(lv2_sql) + length(sqlerrm) + 100) < 32767 THEN
                            lv2_errorMsg := lv2_errorMsg || chr(10) || 'Grant stmt failed: [' || lv2_sql || ']. Error msg: [' || sqlerrm || ']';
                          END IF;
                      END;
                
                   END LOOP;
                
                   IF length(lv2_errorMsg) > length(lv2_errPrefix) THEN
                     ecdp_dynsql.WriteTempText('GRANT_MISSING','Error when executing AddMissingGrantsWrite. The following statements failed:' || chr(10) || lv2_errorMsg);
                   END IF;
                END  AddMissingGrantsWrite;				

                PROCEDURE AddMissingGrantsReport(p_role_name IN VARCHAR2) is
                  CURSOR c_object_to_grant IS
                    SELECT 'GRANT SELECT ON ' || a.object_name || ' to ' || p_role_name || chr(10) text
                    from   user_objects a
                    left join user_tab_privs b on (     b.grantee     = p_role_name
                                                    and b.table_name  = a.object_name
                                                    and b.privilege   = 'SELECT' )
                    where a.object_type = 'VIEW'
                    and a.object_name like 'RV_%'
                    AND   b.grantee is null;
					
                  lv2_sql        VARCHAR2(2000);
                  lv2_errPrefix  VARCHAR2(100) := '-----Grant Stmt Error List:-----';
                  lv2_errorMsg   VARCHAR2(32767) := lv2_errPrefix;
                BEGIN
                  FOR cur_rec IN c_object_to_grant LOOP
                      lv2_sql := cur_rec.text;
                      BEGIN
                         EXECUTE IMMEDIATE lv2_sql;
                      EXCEPTION
                        WHEN OTHERS THEN
                          IF (length(lv2_errorMsg) + length(lv2_sql) + length(sqlerrm) + 100) < 32767 THEN
                            lv2_errorMsg := lv2_errorMsg || chr(10) || 'Grant stmt failed: [' || lv2_sql || ']. Error msg: [' || sqlerrm || ']';
                          END IF;
                      END;
                   END LOOP;
                
                   IF length(lv2_errorMsg) > length(lv2_errPrefix) THEN
                     ecdp_dynsql.WriteTempText('GRANT_MISSING','Error when executing AddMissingGrantsReport. The following statements failed:' || chr(10) || lv2_errorMsg);
                   END IF;
                END  AddMissingGrantsReport;				
             BEGIN
                lv2_operation := UPPER(lv2_operation); -- The grantee name in the Oracle dictionary is in upper case
                ecdp_dynsql.execute_statement('DELETE FROM T_TEMPTEXT WHERE ID = ''GRANT_MISSING''');
                commit;
                AddMissingGrantsReadOnly('APP_READ_ROLE_'  || lv2_operation);   
                AddMissingGrantsWrite   ('APP_WRITE_ROLE_' || lv2_operation);   
                AddMissingGrantsReport  ('REPORT_ROLE_'    || lv2_operation);   
             END;
            ";
	$sth  = $dbh->prepare( $stmt );
	$rv   = $sth->execute();

    $stmt = "SELECT TEXT FROM T_TEMPTEXT WHERE ID = 'GRANT_MISSING' ORDER BY LINE_NUMBER";
	$sth  = $dbh->prepare( $stmt );
	$rv   = $sth->execute();

	my $notfound = 1;
	while(my @row = $sth->fetchrow_array()) {
		my $error_msg = $row[0];
		   $error_msg =~ s/\n//g;
		my @failures  = split(/Grant stmt failed: \[/, $error_msg);
		my $a = 1;
		my @errors_to_report;
		while($a <= $#failures) {
			my @details = split(/\]\. Error msg\: \[/,$failures[$a]);
			$details[1] =~ s/\]//g;
			push(@errors_to_report, [$details[0], $details[1]]) if($details[1] =~ /ORA-01720.*SYS\.ALL/ eq '');
			$a++;
		}

		if($notfound && $#errors_to_report >= 0) {
			Functions->LogAction('E', "Create missing grants had some errors, see details below");
			Functions->LogAction('E', "");
			$notfound = 0;
			$status        = 'WARNING';
			$global_status = $status;
		}
		$a = 0;
		while($a <= $#errors_to_report) {
			Functions->LogAction('E', "Failed statement : $errors_to_report[$a][0]");
			Functions->LogAction('E', "Error message    : $errors_to_report[$a][1]");
			Functions->LogAction('E', "");
			$a++;
		}
	}
	$dbh->disconnect if defined($dbh);
	my $finish      = Functions->GetDateString('yyyymmddhhmiss');
	my $duration    = Functions->DiffDateStrings($start, $finish);
	Functions->LogAction('I', "Missing grants completed with [ $status ] [ $duration ]");
	Functions->LogAction('I', "");

	return 1;
}

sub createMissingSynonyms {
	my ($db_connect_string, $db_usr, $db_pwd) = @_;
	my $start       = Functions->GetDateString('yyyymmddhhmiss');
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', " Creating missing synonyms for schema [ $db_usr ]");
	Functions->LogAction('I', "==================================================================================================");
	Functions->LogAction('I', "");
	my $status = 'SUCCES';
	my $dbh;

	my $conn   = "dbi:Oracle:";
	   $conn  .= "$db_connect_string";

	$dbh       = DBI->connect($conn, $db_usr, $db_pwd, { PrintError => 0,
														 PrintWarn  => 1,
														 RaiseError => 1,
													   });
	my $stmt;
	my $sth;
	my $rv;
	
	$stmt = "DECLARE
               CURSOR c_object_without_synonym(cp_operation VARCHAR2) IS
                 SELECT 'CREATE SYNONYM ' ||  a.object_name || ' FOR ECKERNEL_' || cp_operation || '.' || a.object_name || CHR(10) text
                 FROM   all_objects a
                 WHERE  a.owner = 'ECKERNEL_' || cp_operation
                 AND    a.object_type in ('PACKAGE','VIEW','TABLE','SEQUENCE','TYPE')
                 AND    a.object_name not like 'MLOG\$\%'
                 AND    a.object_name not like 'BIN\$\%'
                 AND    NOT EXISTS ( SELECT 1 
				                     FROM   user_synonyms us
                                     WHERE  us.SYNONYM_NAME = a.object_name
                                     AND    us.TABLE_OWNER = a.owner
                                     AND    us.TABLE_NAME = a.object_name
                                   );

               CURSOR c_synonym_without_object(cp_operation VARCHAR2) IS
                 SELECT 'DROP SYNONYM ' || us.synonym_name || CHR(10) text
                 FROM   user_synonyms us
                 WHERE  NOT EXISTS ( SELECT 1 
			                         FROM   all_objects a
                                     WHERE  a.owner = 'ECKERNEL_' || cp_operation
                                     AND    a.object_name = us.table_name
                                     AND    a.owner = us.table_owner
                                     AND    a.object_name = us.synonym_name
                                   );

               lv2_operation  VARCHAR2(100)   := '$ENV{'operation'}';   
               lv2_sql        VARCHAR2(2000);
               lv2_errPrefix  VARCHAR2(100)   := '-----Synonym Stmt Error List:-----';
               lv2_errorMsg   VARCHAR2(32767) := lv2_errPrefix;
             BEGIN
                lv2_operation := UPPER(lv2_operation); -- The owner name in the Oracle dictionary is in upper case
                
                FOR cur_rec IN c_object_without_synonym(lv2_operation) LOOP
                   lv2_sql := cur_rec.text;
                   BEGIN
                      EXECUTE IMMEDIATE lv2_sql;
                   EXCEPTION
                     WHEN OTHERS THEN
                       IF (length(lv2_errorMsg) + length(lv2_sql) + length(sqlerrm) + 100) < 32767 THEN
                         lv2_errorMsg := lv2_errorMsg || chr(10) || 'Create synonym stmt failed: [' || lv2_sql || ']. Error msg: [' || sqlerrm || ']';
                       END IF;
                   END;
                END LOOP;
             
                FOR cur_rec IN c_synonym_without_object(lv2_operation) LOOP
                   lv2_sql := cur_rec.text;
                   BEGIN
                      EXECUTE IMMEDIATE lv2_sql;
                   EXCEPTION
                     WHEN OTHERS THEN
                       IF (length(lv2_errorMsg) + length(lv2_sql) + length(sqlerrm) + 100) < 32767 THEN
                         lv2_errorMsg := lv2_errorMsg || chr(10) || 'Drop synonym stmt failed: [' || lv2_sql || ']. Error msg: [' || sqlerrm || ']';
                       END IF;
                   END;
                END LOOP;
             
                IF length(lv2_errorMsg) > length(lv2_errPrefix) THEN
                  raise_application_error(-20000, 'Error when executing \"sync_private_synonyms.sql\". The following statements failed:' || chr(10) || lv2_errorMsg);
                END IF;
             END;";
	$sth  = $dbh->prepare( $stmt );
	$rv   = $sth->execute();

#	my $notfound = 1;
#	while(my @row = $sth->fetchrow_array()) {
#		my $error_msg = $row[0];
#		printf("$error_msg\n");
#		   $error_msg =~ s/\n//g;
#		my @failures  = split(/Grant stmt failed: \[/, $error_msg);
#		my $a = 1;
#		my @errors_to_report;
#		while($a <= $#failures) {
#			my @details = split(/\]\. Error msg\: \[/,$failures[$a]);
#			$details[1] =~ s/\]//g;
#			push(@errors_to_report, [$details[0], $details[1]]) if($details[1] =~ /ORA-01720.*SYS\.ALL/ ne '');
#			$a++;
#		}
#
#		if($notfound && $#errors_to_report >= 0) {
#			Functions->LogAction('E', "Create missing grants had some errors, see details below");
#			Functions->LogAction('E', "");
#			$notfound = 0;
#			$status        = 'WARNING';
#			$global_status = $status;
#		}
#		$a = 0;
#		while($a <= $#errors_to_report) {
#			Functions->LogAction('E', "Failed statement : $errors_to_report[$a][0]");
#			Functions->LogAction('E', "Error message    : $errors_to_report[$a][1]");
#			Functions->LogAction('E', "");
#			$a++;
#		}
#	}
	$dbh->disconnect if defined($dbh);
	my $finish      = Functions->GetDateString('yyyymmddhhmiss');
	my $duration    = Functions->DiffDateStrings($start, $finish);
	Functions->LogAction('I', "Missing synonyms completed with [ $status ] [ $duration ]");
	Functions->LogAction('I', "");

	return 1;
}


sub requestPassword {
	my ($parameter, $user_label) = @_;
	if($#adjusted_parameters == -1) {
		Functions->LogAction('I', "");
		Functions->LogAction('I', "Found empty passwords in the operation parameter file, so requesting user input");
		Functions->LogAction('I', "");
		printf("\n");
	}
	push(@adjusted_parameters, $parameter);
	printf("Enter the password for user ".Functions->rpad($user_label, ' ', 20).": ");
	my $userinput = <STDIN>; 
	chomp $userinput;
	$ENV{$parameter} = $userinput;
	setParameterFile($parameter, $userinput);
}

sub setParameterFile {
	my ($parameter, $new_value) = @_;
	my @local_parameters = Files->ReadFileToArray($operation_param);
	my $p = 0;
	
	while($p <= $#local_parameters) {
		my $string = $local_parameters[$p];
		$string    =~ s/''/'$new_value'/g if($string =~ /^define.*$parameter/i ne '');
		Files->Write($operation_param, $string, '>')  if($p == 0);
		Files->Write($operation_param, $string, '>>') if($p  > 0);
		$p++;
	}
}

sub resetParameterFile {
	my $p = 0;
	while($p <= $#parameters) {
		Files->Write($operation_param, $parameters[$p], '>')  if($p == 0);
		Files->Write($operation_param, $parameters[$p], '>>') if($p  > 0);
		$p++;
	}
}

sub exitWithError {
	Functions->LogAction('I', "");
	Functions->LogAction('I', "==================================================================================================");
	my $global_finish   = Functions->GetDateString('yyyymmddhhmiss');
	my $global_duration = Functions->DiffDateStrings($global_start, $global_finish);
	Functions->LogAction('I', "Process finished with [ ERROR ] [ $global_duration ]");
	&resetParameterFile() if($#adjusted_parameters > -1);
	&sendMail();	
	die "\n";
}

sub deldir {
	my ($dirtodel) = @_;

	Functions->LogAction('I', "Start cleaning directory [ $dirtodel ]");
	my $sep        = '\\'; 
	opendir(DIR, $dirtodel);
	my @files      = readdir(DIR);
	closedir(DIR);
	@files         = grep { !/^\.{1,2}/ } @files;
	@files         = map { $_ = "$dirtodel$sep$_"} @files;
	@files         = map { (-d $_)?deldir($_):unlink($_) } @files;
	rmdir($dirtodel);

	Functions->LogAction('I', "Done cleaning directory [ $dirtodel ]");
}

sub sendMail {
	if($ENV{'smtphost'} ne '' && $ENV{'msgTo'} ne '') {
		require MIME::Lite;
		require Net::SMTP_auth;
		$ENV{'smtpport'}   = 25 if($ENV{'smtpport'} eq '');
		my $msgFrom        = 'do_not_reply@jenkins.com';
		my $msgSubject     = "BU - $ENV{'operation'} | $mode [ 00:00:00 ] - ";		
		my $analyze_status = '';
		my $current_user   = '';

		my @log_cnt        = Files->ReadFileToArray($LOG_FILE);
		my $l = 0;       
		my $content        = "<html>\n";
		   $content       .= "\t<head>\n";
		   $content       .= "\t\t<style>\n";
		   $content       .= "\t\t\tbody,td,th  {font-family: verdana; font-size: 9px;}\n";
		   $content       .= "\t\t\ttable       {border: 0px;border-spacing: 2px 0px;}\n";
		   $content       .= "\t\t\tth,td       {padding-left: 5px; padding-top: 0px; padding-bottom: 0px; padding-right: 5px;}\n";
		   $content       .= "\t\t\tth          {color: white;  background-color: black;font-weight: bold; text-align: left; }\n";
		   $content       .= "\t\t\.warn        {color: yellow; background-color: red;  font-weight: bold;   }\n";
		   $content       .= "\t\t\.ok          {color: black;  background-color: green;font-weight: normal; }\n";
		   $content       .= "\t\t\.even        {background-color: #bae0dd; }\n";
		   $content       .= "\t\t\.uneven      {background-color: #b5fcf6; }\n";
		   $content       .= "\t\t</style> \n"; 
		   $content       .= "\t</head>\n";
		   $content       .= "\t<body>\n";
		   $content       .= "\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n";
		   $content       .= "\t\t\t<tr>\n";
		   $content       .= "\t\t\t\t<th width=\"100\"><div align=\"center\">Script type</div></th>\n";
		   $content       .= "\t\t\t\t<th>Script name</th>\n";
		   $content       .= "\t\t\t\t<th width=\"100\"><div align=\"center\">Status</div></th>\n";
		   $content       .= "\t\t\t\t<th width=\"100\"><div align=\"center\">Duration</div></th>\n";
		   $content       .= "\t\t\t\t<th width=\"45\"><div align=\"center\">&lt; 1</div></th>\n";
		   $content       .= "\t\t\t\t<th width=\"45\"><div align=\"center\">1-5</div></th>\n";
		   $content       .= "\t\t\t\t<th width=\"45\"><div align=\"center\">5-10</div></th>\n";
		   $content       .= "\t\t\t\t<th width=\"45\"><div align=\"center\">10-60</div></th>\n";
		   $content       .= "\t\t\t\t<th width=\"45\"><div align=\"center\">&gt 60</div></th>\n";
		   $content       .= "\t\t\t</tr>\n";
		my $r = 0;
		while($l <= $#log_cnt) {
             if($log_cnt[$l] =~ /Done\s{1,2}executing ([^\s]+).*\[ .*\/([^\/]+\.\w{1,}) \] with \[ (.*) \] \[ (\d\d:\d\d:\d\d) \]/ ne '') {
             	$r++;
             	my $style;
             	my $row_style  = 'uneven';
             		$row_style  = 'even' if( $r%2 == 0 );
             	my $scripttype = $1;
             	my $scriptname = $2;
             	my $status     = $3;
             	my $duration   = $4;
             	$content      .= "\t\t\t<tr class=\"$row_style\">\n";
             	$content      .= "\t\t\t\t<td align=\"center\">$scripttype</td>\n";
             	$content      .= "\t\t\t\t<td>$scriptname</td>\n";
             	$style         = 'warn' if( $status eq 'WARNING' || $status eq 'ERROR' );
             	$style         = 'ok'   if( $status eq 'SUCCES'  );
             	$content      .= "\t\t\t\t<td align=\"center\" class=\"$style\">$status</td>\n";
             	$content      .= "\t\t\t\t<td align=\"center\">$duration</td>\n";
             	$content      .= &durationCategory($duration);
             	$content      .= "\t\t\t</tr>\n";
             }
             elsif($log_cnt[$l] =~ /Process finished with \[ (.*) \] \[ (\d\d:\d\d:\d\d) \]/ ne '') {
             	$r++;
             	my $style;
             	my $row_style  = 'uneven';
             		$row_style  = 'even' if( $r%2 == 0 );
             	my $status     = $1;
             	my $duration   = $2;
             	$content      .= "\t\t\t<tr class=\"$row_style\">\n";
             	$content      .= "\t\t\t\t<th colspan=\"2\"><div align=\"right\">Complete script result</div></th>\n";
             	$style         = 'warn' if( $status eq 'WARNING' || $status eq 'ERROR' );
             	$style         = 'ok'   if( $status eq 'SUCCES'  );
             	$content      .= "\t\t\t\t<td align=\"center\" class=\"$style\">$status</td>\n";
             	$content      .= "\t\t\t\t<td align=\"center\">$duration</td>\n";
             	$content      .= &durationCategory($duration);
             	$content      .= "\t\t\t</tr>\n";
				$msgSubject   =~ s/00:00:00/$duration/g; 
             	$msgSubject   .= $status;
				
             }
             elsif($log_cnt[$l] =~ /Done analyzing for FATAL and ERROR in log file \[.*\] with \[ (.*) \] \[ (\d\d:\d\d:\d\d) \]/ ne '') {
             	$analyze_status = $1;
             }
             elsif($log_cnt[$l] =~ /Done executing headless upgrade tool with \[ (.*) \] \[ (\d\d:\d\d:\d\d) \]/ ne '') {
             	$r++;
             	my $style;
             	my $row_style  = 'uneven';
             	   $row_style  = 'even' if( $r%2 == 0 );
             	my $status     = $1;
             	my $duration   = $2;
             	$status        = $analyze_status if( $analyze_status eq 'WARNING' );
             	$content      .= "\t\t\t<tr class=\"$row_style\">\n";
             	$content      .= "\t\t\t\t<td>&nbsp;</td>\n";
             	$content      .= "\t\t\t\t<td>headless upgrade tool</td>\n";
             	$style         = 'warn' if( $status eq 'WARNING' );
             	$style         = 'ok'   if( $status eq 'SUCCES'  );
             	$content      .= "\t\t\t\t<td align=\"center\" class=\"$style\">$status</td>\n";
             	$content      .= "\t\t\t\t<td align=\"center\">$duration</td>\n";
             	$content      .= &durationCategory($duration);
             	$content      .= "\t\t\t</tr>\n";
             }
             elsif($log_cnt[$l] =~ /for schema \[ (.*) \]/ ne '') {
				$current_user  = $1;
			 }
             elsif($log_cnt[$l] =~ /: (.*) completed with \[ (.*) \] \[ (\d\d:\d\d:\d\d) \]/ ne '') {
             	$r++;
             	my $style;
             	my $row_style  = 'uneven';
             	   $row_style  = 'even' if( $r%2 == 0 );
             	my $action     = $1;
             	my $status     = $2;
             	my $duration   = $3;
				if($action =~ /^Missing/ ne '') {
					$action .= " for schema $current_user";
				}
             	$status        = $analyze_status if( $analyze_status eq 'WARNING' );
             	$content      .= "\t\t\t<tr class=\"$row_style\">\n";
             	$content      .= "\t\t\t\t<td align=\"center\">other</td>\n";
             	$content      .= "\t\t\t\t<td>$action</td>\n";
             	$style         = 'warn' if( $status eq 'WARNING' );
             	$style         = 'ok'   if( $status eq 'SUCCES'  );
             	$content      .= "\t\t\t\t<td align=\"center\" class=\"$style\">$status</td>\n";
             	$content      .= "\t\t\t\t<td align=\"center\">$duration</td>\n";
             	$content      .= &durationCategory($duration);
             	$content      .= "\t\t\t</tr>\n";
             }
             $l++;
		}
		$content   .= "\t\t</table>\n";
		$content   .= "\t</body>\n";
		$content   .= "</html>\n";
		
		foreach(split(/;/, $ENV{'msgTo'})) {
			my $msgTo = $_;
			my $msg       = MIME::Lite::->new( 'To' => $msgTo, 'From' => $msgFrom, 'Subject' => $msgSubject, 'Type' => 'multipart/alternative', );
			my $text_part = MIME::Lite::->new( 'Type' => 'text/plain', 'Data' => 'HTML format is not supported for your email client.', );
			my $html_part = MIME::Lite::->new( 'Type' => 'multipart/related', );
			$html_part->attach( 'Type' => 'text/html', 'Data' => $content, );
			$msg->attach($text_part);
			$msg->attach($html_part);
			$msg->attach( Type        => 'text/plain', Path => $LOG_FILE, Filename => 'upgrade.log', Disposition => 'attachment' );  
			my $email     = $msg->as_string();
			my $smtp      = Net::SMTP_auth->new($ENV{'smtphost'}, Port=>$ENV{'smtpport'}) or die "Can't connect: $@";
			if($ENV{'smtpuser'} ne '') {
			$smtp->auth('PLAIN', $ENV{'smtpuser'}, $ENV{'smtppass'}) or die "Can't authenticate:".$smtp->message();
			}
			$smtp->mail($msgFrom)    or die "Error:".$smtp->message();
			$smtp->recipient($msgTo) or die "Error:".$smtp->message();
			$smtp->data()            or die "Error:".$smtp->message();
			$smtp->datasend($email)  or die "Error:".$smtp->message();
			$smtp->dataend()         or die "Error:".$smtp->message();
			$smtp->quit              or die "Error:".$smtp->message();
		}
	}
}

sub durationCategory {
  my ($duration) = @_;
  my $durationcat;
  if($duration =~ /00:00:/ ne '') {
     $durationcat  = "\t\t\t\t<td align=\"center\">X</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
  } 
  elsif($duration =~ /00:(\d\d):/ ne '') {
    if( $1 < 5 ) {
     $durationcat  = "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">X</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
	}
	elsif( $1 >= 5 && $1 < 10 ) {
     $durationcat  = "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">X</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
	}
	else {
     $durationcat  = "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">X</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
	}
  }
  else {
     $durationcat  = "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">&nbsp;</td>\n";
     $durationcat .= "\t\t\t\t<td align=\"center\">X</td>\n";
  }
  return $durationcat;
}

