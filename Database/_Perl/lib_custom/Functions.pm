package Functions;

use Time::Local;
use Files;

sub LogAction {
        my (undef, $type, $message) = @_;

        my $prefix_string = Functions->GetDateString('yyyy-mm-dd hh:mi:ss ');

        if($type eq 'I') {
                $prefix_string .= 'INFO : ';
        } elsif ($type eq 'W') {
                $prefix_string .= 'WARN : ';
        } elsif ($type eq 'E') {
                $prefix_string .= 'ERROR: ';
        } elsif ($type eq 'D' and $main::DEBUG) {
                $prefix_string .= 'DEBUG: ';
        } else {
                $prefix_string = '';
        }

        printf($prefix_string.$message."\n")                   if($prefix_string ne '' and $main::LOG_TO_CONSOLE);
        Files->Write($main::LOG_FILE, $prefix_string.$message) if($prefix_string ne '' and $main::LOG_TO_FILE);
}

sub GoToSleep {
        my (undef, $time) = @_;
        LogAction('','D', "Wait [ $time ] seconds");
        sleep($time);
}

sub GetDateArray {
        my (undef, $time_back) = @_; # seconds, 86400 is 1 day
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time-$time_back);
        my $date = sprintf("%04d-%02d-%02d %02d:%02d:%02d",$year + 1900,$mon + 1, $mday, $hour, $min, $sec);

        my @date_result;

        push(@date_result, sprintf("%04d",$year + 1900));
        push(@date_result, sprintf("%02d",$mon + 1));
        push(@date_result, sprintf("%02d",$mday));
        push(@date_result, sprintf("%02d",$hour));
        push(@date_result, sprintf("%02d",$min));
        push(@date_result, sprintf("%02d",$sec));

        return @date_result;
}

sub GetDateString {
        my (undef, $format, $time_back) = @_; # seconds, 86400 is 1 day
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time-$time_back);
        my $date = sprintf("%04d-%02d-%02d %02d:%02d:%02d",$year + 1900,$mon + 1, $mday, $hour, $min, $sec);

        my $result = "";
        my @date_result;

        push(@date_result, sprintf("%04d",$year + 1900));
        push(@date_result, sprintf("%02d",$mon + 1));
        push(@date_result, sprintf("%02d",$mday));
        push(@date_result, sprintf("%02d",$hour));
        push(@date_result, sprintf("%02d",$min));
        push(@date_result, sprintf("%02d",$sec));

        if($format ne '') {
                $format = lc($format);
                $format =~ s/yyyy/$date_result[0]/g;
                $format =~ s/mm/$date_result[1]/g;
                $format =~ s/dd/$date_result[2]/g;
                $format =~ s/hh/$date_result[3]/g;
                $format =~ s/mi/$date_result[4]/g;
                $format =~ s/ss/$date_result[5]/g;
                $result = $format;
        } else {
                $result = $date_result[0].'-'.$date_result[1].'-'.$date_result[2].' '.$date_result[3].':'.$date_result[4].':'.$date_result[5];
        }

        return $result;
}

sub DiffDateStrings {
	my (undef, $start_date, $end_date) = @_;
 
	my @parts = ($start_date.'.000') =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})\.(\d{3})$/;
	$parts[1]--; #the month is not 1-12 but 0-11
	my $start_secs = pop(@parts) / 1000;
	$start_secs += timegm reverse @parts;
	
	@parts = ($end_date.'.000') =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})\.(\d{3})$/;
	$parts[1]--; #the month is not 1-12 but 0-11
	my $finish_secs = pop(@parts) / 1000;
	$finish_secs += timegm reverse @parts;

	my $diff    = $finish_secs - $start_secs;
    my $hours   = 0;
	   $hours   = ($diff - ($diff % (60*60))) / (60*60)       if($diff >= (60*60));
    my $minutes = 0;
	   $minutes = (($diff - ($diff % 60)) / 60) - ($hours*60) if($diff >= (60));
    my $seconds = $diff - ($hours*60*60) - ($minutes*60);

	return Functions->lpad($hours,'0',2).":".Functions->lpad($minutes,'0',2).":".Functions->lpad($seconds,'0',2);
}

sub rpad {
        my (undef, $string, $adding, $length) = @_;
        return($string . $adding x ($length - length($string)));
}

sub lpad {
        my (undef, $string, $adding, $length) = @_;
        return($adding x ($length - length($string)) . $string);
}

1;
