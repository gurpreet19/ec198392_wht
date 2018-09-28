package Files;

use Functions;

sub Write {
        my (undef, $file, $line, $mode) = @_;
        $mode = '>>' if($mode eq '');
        open FILE_TO_WRITE, $mode.$file or die $!;
        print FILE_TO_WRITE "$line\n";
        close(FILE_TO_WRITE);
}

sub ReadConfig
{
        my (undef, $config_file) = @_;
        Functions->LogAction('I', "Using configuration file [ $config_file ]");

        if (-e $config_file) {
                Functions->LogAction('D', "[ReadConfig] File found [ $config_file ]");
        } else {
                Functions->LogAction('E', "File not found [ $config_file ]");
                exit;
        }

        if (-r $config_file) {
                Functions->LogAction('D', "[ReadConfig] File can be read [ $config_file ]");
        } else {
                Functions->LogAction('E', "File is not readable [ $config_file ]");
                exit;
        }

        if (-d $config_file) {
                Functions->LogAction('E', "Config file is not a file but a directory [ $config_file ]");
                exit;
        }

        open CONFIG_FILE, "< $config_file" or die $!;
        while (my $line = <CONFIG_FILE>) {
                chomp($line);
                Functions->LogAction('D', "[ReadConfig] Found entry in configuration file [ $line ]");
                my @splitted = split(/=/, $line);
                $splitted[0] =~ s/^\s*//;
                $splitted[1] =~ s/^\s*//;
                $splitted[0] =~ s/\s*$//;
                $splitted[1] =~ s/\s*$//;
                Functions->LogAction('D', "[ReadConfig] Found key   [ $splitted[0] ]");
                Functions->LogAction('D', "[ReadConfig] Found value [ $splitted[1] ]");
                $main::ConfigHash{$splitted[0]} = $splitted[1];
        }
        close(CONFIG_FILE);
}

sub ReadFileToArray {
        my (undef, $file) = @_;
        my @result;
        open(FILE_TO_READ, "< $file") or die "Couldn't open file $file for reading: $!";
        while(my $line = <FILE_TO_READ>) {
                chomp($line);
                push(@result, $line);
        }
        close(FILE_TO_READ);
        return @result;
}

sub ReadFileToString {
        my (undef, $file) = @_;
        my $result;
        open(FILE_TO_READ, "< $file") or die "Couldn't open file $file for reading: $!";
        while(my $line = <FILE_TO_READ>) {
                chomp($line);
                $result .= "$line\n";
        }
        close(FILE_TO_READ);
        return $result;
}

1;
