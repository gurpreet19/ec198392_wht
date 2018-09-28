# This file is auto-generated by the Perl DateTime Suite time zone
# code generator (0.08) This code generator comes with the
# DateTime::TimeZone module distribution in the tools/ directory

#
# Generated from /tmp/Lmk3a2MG67/northamerica.  Olson data version 2017b
#
# Do not edit this file directly.
#
package DateTime::TimeZone::HST;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '2.13';

use Class::Singleton 1.03;
use DateTime::TimeZone;
use DateTime::TimeZone::OlsonDB;

@DateTime::TimeZone::HST::ISA = ( 'Class::Singleton', 'DateTime::TimeZone' );

my $spans =
[
    [
DateTime::TimeZone::NEG_INFINITY, #    utc_start
DateTime::TimeZone::INFINITY, #      utc_end
DateTime::TimeZone::NEG_INFINITY, #  local_start
DateTime::TimeZone::INFINITY, #    local_end
-36000,
0,
'HST',
    ],
];

sub olson_version {'2017b'}

sub has_dst_changes {0}

sub _max_year {2027}

sub _new_instance {
    return shift->_init( @_, spans => $spans );
}



1;

