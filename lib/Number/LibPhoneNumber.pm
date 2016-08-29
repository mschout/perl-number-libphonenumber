package Number::LibPhoneNumber;
$Number::LibPhoneNumber::VERSION = '0.02';
# ABSTRACT: Perl interface to Goole's libphonenumber

use strict;
use warnings;

require Exporter;

require XSLoader;
XSLoader::load('Number::LibPhoneNumber', $Number::LibPhoneNumber::VERSION);


sub format_using {
    my ($self, $format) = @_;

    eval "use Number::Phone::Formatter::$format";
    if ($@) {
        die "Could not load $format formatter: $@\n";
    }

    return "Number::Phone::Formatter::$format"->format($self->format('international'));
}


1;

__END__

=pod

=head1 NAME

Number::LibPhoneNumber - Perl interface to Goole's libphonenumber

=head1 VERSION

version 0.02

=head1 SYNOPSIS

  use Number::LibPhoneNumber;

  my $phone = Number::LibPhoneNumber->new('+1 311-555-2368', 'US')
    or die "invalid phone number: $@";

  say $phone->national_number;
  say $phone->country_code;

  # formatting
  say $phone->format;
  say $phone->format('international');
  say $phone->format('national');

  # use Number::Phone::Formatter format plugins
  say $phone->format_using('EPP');
  say $phone->format_using('Raw');

=head1 DESCRIPTION

This is a Perl interface to Google's libphonenumber.  At this time only a
minimal set of the interface is ported over to perl.  Just enough to do what we
needed at the time.

=head1 METHODS

=head2 new($number, $country='ZZ')

Constructor Takes a phone number string and a country 2 letter value such aAs
C<US>. Returns undef if the number is not valid.  Note that B<valid> here means
the same thing as C<IsValid()> in google libphonenumber. That is, the number
meets formatting requirements for the given country.  It is not possible to
know if the number is in use or not simply by looking at the number.  The
C<$country> may be omitted.  C<$number> can be anything that libphonenumber's
C<Parse()> method understands.

=head2 country_code(): int

Get the country dialing code.

=head2 extension(): string

Get the value of the extension (if present), undef otherwise.

=head2 national_number(): string

Get the national number portion of the phone number.

=head2 format_using($format): string

Format the number using the given formatter. The C<$format> parameter can be
anything that L<Number::Phone>'s C<format_using()> method accepts.  E.g.:

 # use Number::Phone::Formatter::Raw
 $obj->format_using('Raw');

 # use Number::Phone::Formatter::EPP
 $obj->format_using('EPP');

=head2 format($format): string

Return formatted string representation of the phone number in the given format.
The C<$format> parameter can be either C<international> or C<national>.  The
default is C<international>.

E.g.:

 $obj->format();                # -> +1 311-555-2368
 $obj->format('international'); # -> +1 311-555-2368
 $obj->format('national');      # -> (311) 555-2368

=head2 is_valid(): bool

Returns true if the number is valid.

=head2 type(): string

Returns the type of number.  This will be one of the following values.

=over 4

=item *

fixed line

=item *

mobile

=item *

fixed line or mobile

=item *

toll free

=item *

premium rate

=item *

shared cost

=item *

voip

=item *

personal number

=item *

pager

=item *

uan

=item *

voicemail

=item *

unknown

=back

=head1 SOURCE

The development version is on github at L<http://github.com/mschout/perl-number-libphonenumber>
and may be cloned from L<git://github.com/mschout/perl-number-libphonenumber.git>

=head1 BUGS

Please report any bugs or feature requests to bug-number-libphonenumber@rt.cpan.org or through the web interface at:
 http://rt.cpan.org/Public/Dist/Display.html?Name=Number-LibPhoneNumber

=head1 AUTHOR

Michael Schout <mschout@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Michael Schout.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
