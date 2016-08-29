
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "XSUB.h"
#include "phone_number.hpp"
#include "perl.h"
#include "ppport.h"

using std::string;
using i18n::phonenumbers::PhoneNumberUtil;
using i18n::phonenumbers::PhoneNumber;

void
set_phone_error(PhoneNumberUtil::ErrorType error) {
    switch (error) {
        case PhoneNumberUtil::ErrorType::NO_PARSING_ERROR:
            // no error.
            break;

        case PhoneNumberUtil::ErrorType::INVALID_COUNTRY_CODE_ERROR:
            sv_setpv(ERRSV, "Invalid country code");
            break;

        case PhoneNumberUtil::ErrorType::NOT_A_NUMBER:
            sv_setpv(ERRSV, "Not a number");
            break;

        case PhoneNumberUtil::ErrorType::TOO_SHORT_AFTER_IDD:
            sv_setpv(ERRSV, "Too short after IDD");
            break;

        case PhoneNumberUtil::ErrorType::TOO_SHORT_NSN:
            sv_setpv(ERRSV, "National number is too short");
            break;

        case PhoneNumberUtil::ErrorType::TOO_LONG_NSN:
            sv_setpv(ERRSV, "National number is too long");
            break;

        default:
            break;
    }
}

MODULE = Number::LibPhoneNumber		PACKAGE = Number::LibPhoneNumber

phone_number *
phone_number::new(number, country="ZZ")
        string number
        string country
    INIT:
        PhoneNumber ph_num;
        auto phone_util = PhoneNumberUtil::GetInstance();

        auto error = phone_util->Parse(number, country, &ph_num);
        if (error != PhoneNumberUtil::NO_PARSING_ERROR) {
            set_phone_error(error);
            XSRETURN_UNDEF;
        }

        if (!phone_util->IsValidNumber(ph_num)) {
            sv_setpv(ERRSV, "Invalid phone number");
            XSRETURN_UNDEF;
        }
    CODE:
        RETVAL = new phone_number(ph_num);
    OUTPUT:
        RETVAL

void
phone_number::DESTROY()

string
phone_number::national_number()

int
phone_number::country_code()

string
phone_number::extension()

bool
phone_number::is_valid()

string
phone_number::type()

string
phone_number::format(number_format="international")
        string number_format
    CODE:
        if (!strcasecmp(number_format.c_str(), "national")) {
            RETVAL = THIS->format(PhoneNumberUtil::PhoneNumberFormat::NATIONAL);
        }
        else if (!strcasecmp(number_format.c_str(), "E.164") || !strcasecmp(number_format.c_str(), "E164")) {
            RETVAL = THIS->format(PhoneNumberUtil::PhoneNumberFormat::E164);
        }
        else {
            RETVAL = THIS->format(PhoneNumberUtil::PhoneNumberFormat::INTERNATIONAL);
        }
    OUTPUT:
        RETVAL



