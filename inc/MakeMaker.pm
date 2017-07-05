package inc::MakeMaker;

use Moose;

extends qw(Dist::Zilla::Plugin::MakeMaker::Awesome);

override _build_WriteMakefile_args => sub {
    +{
        %{ super() },
        LIBS => [ '-lphonenumber' ],
        OBJECT => 'phone_number.o LibPhoneNumber.o'
    }
};

override _build_header => sub {
    my $header = super();

    $header .= <<'EOT';
use ExtUtils::CppGuess;
use Devel::CheckLib;

my $guess = ExtUtils::CppGuess->new;
my @compiler_flags = ('-std=c++11');
my @linker_flags;

sub get_command_line_params {
    my %params;

    for my $param (map { "LIBPHONENUMBER_$_" } qw(INCLUDE LIB)) {
        $params{$param} = $ENV{$param};
    }

    # remove config vars from @ARGV
    @ARGV = grep {
        my ($key, $val) = split /=/, $_, 2;
        if (exists $params{$key}) {
            $params{$key} = $val;
            0;
        }
        else {
            1;
        }
    } @ARGV;

    return %params;
}

my %params = get_command_line_params();

if (defined $params{LIBPHONENUMBER_INCLUDE}) {
    push @compiler_flags, "-I$params{LIBPHONENUMBER_INCLUDE}";
}
if (defined $params{LIBPHONENUMBER_LIB}) {
    push @linker_flags, "-L$params{LIBPHONENUMBER_LIB}";
}

if ($] < 5.020000) {
    if ($^O eq 'darwin') {
        # 5.18 and earler need this flag on OS X
        push @compiler_flags, '-Wno-reserved-user-defined-literal';
    }
}

push @linker_flags, '-lphonenumber';

$guess->add_extra_compiler_flags(join ' ', @compiler_flags);
$guess->add_extra_linker_flags(join ' ', @linker_flags);

my %mb_opts = $guess->module_build_options;

check_lib_or_exit(
    lib     => 'phonenumber',
    header  => 'phonenumbers/phonenumberutil.h',
    libpath => $params{LIBPHONENUMBER_LIB},
    incpath => $params{LIBPHONENUMBER_INCLUDE},
    ccflags => $mb_opts{extra_compiler_flags},
    ldflags => $mb_opts{extra_linker_flags});
EOT

    return $header;
};

override _build_WriteMakefile_dump => sub {
    my $str = super();


    $str =~ s|\);\s+$|, \$guess->makemaker_options);|s;

    return $str;
};

1;
