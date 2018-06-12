#!/usr/bin/env perl
#
# Note: most of the numbers tested here come from google's libphonenumber test suite
#

use strict;
use warnings;
use Test::More tests => 16;

use_ok 'Number::LibPhoneNumber' or exit 1;

my $obj = Number::LibPhoneNumber->new("+1 650-253-0000", "US");
is $obj->national_number, '6502530000';
is $obj->country_code, '1';
is $obj->format, '+1 650-253-0000';
is $obj->format('international'), '+1 650-253-0000';
is $obj->format('national'), '(650) 253-0000';

subtest invalid_numbers => sub {
    my @tests = (
        '+1 2530000',
        '+39 23661830000',
        '+44 791234567',
        '+49 1234',
        '+64 3316005',
        '+3923 2366',
        '+800 123456789');

    plan tests => 2 * scalar @tests;

    for my $num (@tests) {
        ok !defined Number::LibPhoneNumber->new($num);
        is $@, 'Invalid phone number';
    }
};

subtest is_valid => sub {
    my @tests = (
        '+1 6502530000',
        '+39 0236618300',
        '+44 7912345678',
        '+64 21387835',
        '+800 12345678',
        '+979 123456789'
    );

    plan tests => 2 * scalar @tests;

    for my $num (@tests) {
        my $obj = new_ok 'Number::LibPhoneNumber', [$num], "$num is valid";
        ok $obj->is_valid, "is_valid $num";
    }
};

subtest country_code => sub {
    my %tests = (
        '+1 6502530000'  => 1,
        '+39 0236618300' => 39,
        '+44 7912345678' => 44,
        '+64 21387835'   => 64,
        '+800 12345678'  => 800,
        '+979 123456789' => 979);

    plan tests => 2 * scalar keys %tests;

    while (my ($num, $cc) = each %tests) {
        my $obj = new_ok 'Number::LibPhoneNumber', [$num];
        is $obj->country_code, $cc;
    }
};

subtest national_number => sub {
    my %tests = (
        '+1 6502530000'  => '6502530000',
        '+39 0236618300' => '0236618300',
        '+44 7912345678' => '7912345678',
        '+64 21387835'   => '21387835',
        '+800 12345678'  => '12345678',
        '+979 123456789' => '123456789');

    plan tests => 2 * scalar keys %tests;

    while (my ($num, $natl) = each %tests) {
        my $obj = new_ok 'Number::LibPhoneNumber', [$num];
        is $obj->national_number, $natl;
    }
};

subtest extension => sub {
    my %tests = (
        '+1 6502530000 ext. 1234'  => '1234',
        '+1 6502530000 ext. 1234#' => '1234',
        '+1 6502530000 - 1234#'    => '1234',
        '+1 650253-0000'           => '');

    plan tests => 2* scalar keys %tests;

    while (my ($num, $ext) = each %tests) {
        my $obj = new_ok 'Number::LibPhoneNumber', [$num];
        is $obj->extension, $ext;
    }
};

subtest type => sub {
    plan tests => 42;

    my %tests = (
        'premium rate' => [
            '+1 9004433030',
            '+39 892123',
            '+44 9187654321',
            '+49 9001654321',
            '+49 90091234567',
            '+979 123456789'
        ],
        'toll free' => [
            '+1 8882134567',
            '+39 803123',
            '+49 8001234567',
            '+800 12345678'
        ],
        mobile => [
            '+1 2423570000',
            '+44 7912345678',
            '+49 15123456789',
            '+54 91187654321'
        ],
        'fixed line' => [
            '+1 2423651234',
            '+44 2012345678',
            '+49 301234'
        ],
        'fixed line or mobile' => [
            '+1 6502531111'
        ],
        'shared cost' => [
            '+44 8431231234',
        ],
        'voip' => [
            '+44 5631231234'
        ],
        'personal number' => [
            '+44 7031231234'
        ]
    );

    while (my ($type, $nums) = each %tests) {
        for my $num (@$nums) {
            note $num;
            my $obj = new_ok 'Number::LibPhoneNumber', [$num];
            is $obj->type, $type, "type: $type";
        }
    }
};

subtest format => sub {
    plan tests => 43;

    my %tests = (
        '+1 6502530000' => {
            international => '+1 650-253-0000',
            national      => '(650) 253-0000',
            E164          => '+16502530000'
        },
        '+39 0236618300' => {
            international => '+39 02 3661 8300',
            national      => '02 3661 8300',
            E164          => '+390236618300'
        },
        '+44 7912345678' => {
            international => '+44 7912 345678',
            national      => '07912 345678',
            E164          => '+447912345678'
        },
        '+64 21387835' => {
            international => '+64 21 387 835',
            national      => '021 387 835',
            E164          => '+6421387835'
        },
        '+800 12345678' => {
            international => '+800 1234 5678',
            national      => '1234 5678',
            E164          => '+80012345678'
        },
        '+979 123456789' => {
            international => '+979 1 2345 6789',
            national      => '1 2345 6789',
            E164          => '+979123456789'
        }
    );

    while (my ($num, $t) = each %tests) {
        while (my ($format, $expect) = each %$t) {
            my $obj = new_ok 'Number::LibPhoneNumber', [$num];
            is $obj->format($format), $expect, "$format format of $num";
        }
    }

    # test variants of E164 format
    my $obj = new_ok 'Number::LibPhoneNumber', ['+1 6502530000'];
    is $obj->format('E.164'), '+16502530000', 'format E.164';
    is $obj->format('e164'), '+16502530000', 'format e164';
    is $obj->format('e.164'), '+16502530000', 'format e.164';
    is $obj->format('RFC3966'), 'tel:+1-650-253-0000', 'format e.164';
    is $obj->format('rfc3966'), 'tel:+1-650-253-0000', 'format e.164';

    is $obj->format, '+1 650-253-0000', 'default format is international';
};

subtest invalid_svtype => sub {
    my %item = (number => '2423570000', country_code => 'US');

    my $obj = new_ok 'Number::LibPhoneNumber', [2423570000, 'US'];
    is $obj->format, '+1 242-357-0000';
};

subtest region_code_for_country_code => sub {
    is Number::LibPhoneNumber->region_code_for_country(1), 'US';
    is Number::LibPhoneNumber->region_code_for_country(64), 'NZ';
};

subtest country_code_for_region => sub {
    cmp_ok(Number::LibPhoneNumber->country_code_for_region('US'), '==', 1);
    cmp_ok(Number::LibPhoneNumber->country_code_for_region('CA'), '==', 1);
    cmp_ok(Number::LibPhoneNumber->country_code_for_region('NZ'), '==', 64);
};
