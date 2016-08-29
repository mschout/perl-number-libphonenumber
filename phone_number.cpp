#include "phone_number.hpp"

using std::string;
using i18n::phonenumbers::PhoneNumberUtil;
using i18n::phonenumbers::PhoneNumber;

string
phone_number::format(const PhoneNumberUtil::PhoneNumberFormat& number_format) const
{
    string formatted;

    phone_util().Format(m_number, number_format, &formatted);

    return formatted;
}

string
phone_number::type() const
{
    auto type = phone_util().GetNumberType(m_number);

    switch (type) {
        case PhoneNumberUtil::FIXED_LINE:
            return "fixed line";
        case PhoneNumberUtil::MOBILE:
            return "mobile";
        case PhoneNumberUtil::FIXED_LINE_OR_MOBILE:
            return "fixed line or mobile";
        case PhoneNumberUtil::TOLL_FREE:
            return "toll free";
        case PhoneNumberUtil::PREMIUM_RATE:
            return "premium rate";
        case PhoneNumberUtil::SHARED_COST:
            return "shared cost";
        case PhoneNumberUtil::VOIP:
            return "voip";
        case PhoneNumberUtil::PERSONAL_NUMBER:
            return "personal number";
        case PhoneNumberUtil::PAGER:
            return "pager";
        case PhoneNumberUtil::UAN:
            return "uan";
        case PhoneNumberUtil::VOICEMAIL:
            return "voicemail";
        default:
            return "unknown";
    }
}

bool
phone_number::is_valid() const
{
    return phone_util().IsValidNumber(m_number);
}

string
phone_number::national_number() const
{
    string natl_num;

    // simply returning m_number.get_national_number() is undesirable becuase
    // it discards leading zeros. This method preserves that.
    phone_util().GetNationalSignificantNumber(m_number, &natl_num);

    return natl_num;
}
