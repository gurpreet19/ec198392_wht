package lib;

# THIS FILE IS AUTOMATICALLY GENERATED FROM lib_pm.PL.
# ANY CHANGES TO THIS FILE WILL BE OVERWRITTEN BY THE NEXT PERL BUILD.

use Config;

use strict;

my $archname         = $Config{archname};
my $version          = $Config{version};
my @inc_version_list = reverse split / /, $Config{inc_version_list};


our @ORIG_INC = @INC;	# take a handy copy of 'original' value
our $VERSION = '0.64';

sub import {
    shift;

    my %names;
    foreach (reverse @_) {
	my $path = $_;		# we'll be modifying it, so break the alias
	if ($path eq '') {
	    require Carp;
	    Carp::carp("Empty compile time value given to use lib");
	}

	if ($path !~ /\.par$/i && -e $path && ! -d _) {
	    require Carp;
	    Carp::carp("Parameter to use lib must be directory, not file");
	}
	unshift(@INC, $path);
	# Add any previous version directories we found at configure time
	foreach my $incver (@inc_version_list)
	{
	    my $dir = "$path/$incver";
	    unshift(@INC, $dir) if -d $dir;
	}
	# Put a corresponding archlib directory in front of $path if it
	# looks like $path has an archlib directory below it.
	my($arch_auto_dir, $arch_dir, $version_dir, $version_arch_dir)
	    = _get_dirs($path);
	unshift(@INC, $arch_dir)         if -d $arch_auto_dir;
	unshift(@INC, $version_dir)      if -d $version_dir;
	unshift(@INC, $version_arch_dir) if -d $version_arch_dir;
    }

    # remove trailing duplicates
    @INC = grep { ++$names{$_} == 1 } @INC;
    return;
}


sub unimport {
    shift;

    my %names;
    foreach my $path (@_) {
	my($arch_auto_dir, $arch_dir, $version_dir, $version_arch_dir)
	    = _get_dirs($path);
	++$names{$path};
	++$names{$arch_dir}         if -d $arch_auto_dir;
	++$names{$version_dir}      if -d $version_dir;
	++$names{$version_arch_dir} if -d $version_arch_dir;
    }

    # Remove ALL instances of each named directory.
    @INC = grep { !exists $names{$_} } @INC;
    return;
}

sub _get_dirs {
    my($dir) = @_;
    my($arch_auto_dir, $arch_dir, $version_dir, $version_arch_dir);

    $arch_auto_dir    = "$dir/$archname/auto";
    $arch_dir         = "$dir/$archname";
    $version_dir      = "$dir/$version";
    $version_arch_dir = "$dir/$version/$archname";

    return($arch_auto_dir, $arch_dir, $version_dir, $version_arch_dir);
}

1;
__END__

=head1 NAME

lib - manipulate @INC at compile time

=head1 SYNOPSIS

    use lib LIST;

    no lib LIST;

=head1 DESCRIPTION

This is a small simple module which simplifies the manipulation of @INC
at compile time.

It is typically used to add extra directories to perl's search path so
that later C<use> or C<require> statements will find modules which are
not located on perl's default search path.

=head2 Adding directories to @INC

The parameters to C<use lib> are added to the start of the perl search
path. Saying

    use lib LIST;

is I<almost> the same as saying

    BEGIN { unshift(@INC, LIST) }

For each directory in LIST (called $dir here) the lib module also
checks to see if a directory called $dir/$archname/auto exists.
If so the $dir/$archname directory is assumed to be a corresponding
architecture specific directory and is added to @INC in front of $dir.
lib.pm also checks if directories called $dir/$version and $dir/$version/$archname
exist and adds these directories to @INC.

The current value of C<$archname> can be found with this command:

    perl -V:archname

The corresponding command to get the current value of C<$version> is:

    perl -V:version

To avoid memory leaks, all trailing duplicate entries in @INC are
removed.

=head2 Deleting directories from @INC

You should normally only add directories to @INC.  If you need to
delete directories from @INC take care to only delete those which you
added yourself or which you are certain are not needed by other modules
in your script.  Other modules may have added directories which they
need for correct operation.

The C<no lib> statement deletes all instances of each named directory
from @INC.

For each directory in LIST (called $dir here) the lib module also
checks to see if a directory called $dir/$archname/auto exists.
If so the $dir/$archname directory is assumed to be a corresponding
architecture specific directory and is also deleted from @INC.

=head2 Restoring original @INC

When the lib module is first loaded it records the current value of @INC
in an array C<@lib::ORIG_INC>. To restore @INC to that value you
can say

    @INC = @lib::ORIG_INC;

=head1 CAVEATS

In order to keep lib.pm small and simple, it only works with Unix
filepaths.  This doesn't mean it only works on Unix, but non-Unix
users must first translate their file paths to Unix conventions.

    # VMS users wanting to put [.stuff.moo] into 
    # their @INC would write
    use lib 'stuff/moo';

=head1 NOTES

In the future, this module will likely use File::Spec for determining
paths, as it does now for Mac OS (where Unix-style or Mac-style paths
work, and Unix-style paths are converted properly to Mac-style paths
before being added to @INC).

If you try to add a file to @INC as follows:

  use lib 'this_is_a_file.txt';

C<lib> will warn about this. The sole exceptions are files with the
C<.par> extension which are intended to be used as libraries.

=head1 SEE ALSO

FindBin - optional module which deals with paths relative to the source file.

PAR - optional module which can treat C<.par> files as Perl libraries.

=head1 AUTHOR

Tim Bunce, 2nd June 1995.

C<lib> is maintained by the perl5-porters. Please direct
any questions to the canonical mailing list. Anything that
is applicable to the CPAN release can be sent to its maintainer,
though.

Maintainer: The Perl5-Porters <perl5-porters@perl.org>

Maintainer of the CPAN release: Steffen Mueller <smueller@cpan.org>

=head1 COPYRIGHT AND LICENSE

This package has been part of the perl core since perl 5.001.
It has been released separately to CPAN so older installations
can benefit from bug fixes.

This package has the same copyright and license as the perl core.

=cut
