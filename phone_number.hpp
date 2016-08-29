#ifndef PHONE_NUMBER_HPP
#define PHONE_NUMBER_HPP

#include <phonenumbers/phonenumberutil.h>
#include <string>

class phone_number {
    public:
        phone_number(const i18n::phonenumbers::PhoneNumber& number):
            m_number(number) {};

        int country_code() const {
            return m_number.country_code();
        }

        // note that we return a string here in order to avoid dealing with
        // trying to figure out if perl's IV supports 64 bit ints or not.
        std::string national_number() const;

        std::string extension() const {
            return m_number.extension();
        };

        std::string format(const i18n::phonenumbers::PhoneNumberUtil::PhoneNumberFormat& number_format) const;

        bool is_valid() const;

        std::string type() const;

    protected:
        i18n::phonenumbers::PhoneNumberUtil& phone_util() const {
            return *i18n::phonenumbers::PhoneNumberUtil::GetInstance();
        };

        i18n::phonenumbers::PhoneNumber m_number;
};

#endif
