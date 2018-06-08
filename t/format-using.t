#!/usr/bin/env perl
#

use strict;
use warnings;
use Test::More;

unless (eval { require Number::Phone::Formatter::Raw; 1 }) {
    plan skip_all => 'Number::Phone v3.1 or later is required for this test';
}
else {
    plan tests => 3;
}

use_ok 'Number::LibPhoneNumber' or exit ;

my $num = new_ok 'Number::LibPhoneNumber', ['+1 6502530000'];

is $num->format_using('Raw'), '6502530000';


