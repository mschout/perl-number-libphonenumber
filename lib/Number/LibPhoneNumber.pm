package Number::LibPhoneNumber;

# ABSTRACT: Perl interface to Goole's libphonenumber

use strict;
use warnings;

require Exporter;

require XSLoader;
XSLoader::load('Number::LibPhoneNumber', $Number::LibPhoneNumber::VERSION);

=method new($number, $country='ZZ')

Constructor Takes a phone number string and a country 2 letter value such aAs
C<US>. Returns undef if the number is not valid.  Note that B<valid> here means
the same thing as C<IsValid()> in google libphonenumber. That is, the number
meets formatting requirements for the given country.  It is not possible to
know if the number is in use or not simply by looking at the number.  The
C<$country> may be omitted.  C<$number> can be anything that libphonenumber's
C<Parse()> method understands.

=method country_code(): int

Get the country dialing code.

=method extension(): string

Get the value of the extension (if present), undef otherwise.

=method national_number(): string

Get the national number portion of the phone number.

=method format_using($format): string

Format the number using the given formatter. The C<$format> parameter can be
anything that L<Number::Phone>'s C<format_using()> method accepts.  E.g.:

 # use Number::Phone::Formatter::Raw
 $obj->format_using('Raw');

 # use Number::Phone::Formatter::EPP
 $obj->format_using('EPP');

=cut

sub format_using {
    my ($self, $format) = @_;

    eval "use Number::Phone::Formatter::$format";
    if ($@) {
        die "Could not load $format formatter: $@\n";
    }

    return "Number::Phone::Formatter::$format"->format($self->format('international'));
}

=method format($format): string

Return formatted string representation of the phone number in the given format.
The C<$format> parameter can be either C<international> or C<national>.  The
default is C<international>.

E.g.:

 $obj->format();                # -> +1 311-555-2368
 $obj->format('international'); # -> +1 311-555-2368
 $obj->format('national');      # -> (311) 555-2368

=method is_valid(): bool

Returns true if the number is valid.

=method type(): string

Returns the type of number.  This will be one of the following values.

=for :list
* fixed line
* mobile
* fixed line or mobile
* toll free
* premium rate
* shared cost
* voip
* personal number
* pager
* uan
* voicemail
* unknown

=cut

1;

__END__

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

=cut
