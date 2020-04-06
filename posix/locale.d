/**
 * D header file for POSIX's <locale.h>.
 *
 * See_Also:  https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/locale.h.html
 * Copyright: D Language Foundation, 2019
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Mathias 'Geod24' Lang
 * Standards: The Open Group Base Specifications Issue 7, 2018 edition
 * Source:    $(DRUNTIMESRC core/sys/posix/_locale.d)
 */
module posix.locale;

import stdint;

version (Posix):
extern(C):
@system:
nothrow:
@nogc:

version (OSX)
    version = OSXBSDLocale;
version (FreeBSD)
    version = OSXBSDLocale;
version (NetBSD)
    version = OSXBSDLocale;
version (DragonFlyBSD)
    version = OSXBSDLocale;


///
struct lconv
{
    char*    currency_symbol;
    char*    decimal_point;
    char     frac_digits;
    char*    grouping;
    char*    int_curr_symbol;
    char     int_frac_digits;
    char     int_n_cs_precedes;
    char     int_n_sep_by_space;
    char     int_n_sign_posn;
    char     int_p_cs_precedes;
    char     int_p_sep_by_space;
    char     int_p_sign_posn;
    char*    mon_decimal_point;
    char*    mon_grouping;
    char*    mon_thousands_sep;
    char*    negative_sign;
    char     n_cs_precedes;
    char     n_sep_by_space;
    char     n_sign_posn;
    char*    positive_sign;
    char     p_cs_precedes;
    char     p_sep_by_space;
    char     p_sign_posn;
    char*    thousands_sep;
}

/// Duplicate existing locale
locale_t duplocale(locale_t locale);
/// Free an allocated locale
void     freelocale(locale_t locale);
/// Natural language formatting for C
lconv*   localeconv();
/// Create a new locale
locale_t newlocale(int mask, const char* locale, locale_t base);
/// Set the C library's notion of natural language formatting style
char*    setlocale(int category, const char* locale);
/// Set the per-thread locale
locale_t uselocale (locale_t locale);

version (OSXBSDLocale)
{
    ///
    enum
    {
        LC_ALL      = 0,
        LC_COLLATE  = 1,
        LC_CTYPE    = 2,
        LC_MESSAGES = 6,
        LC_MONETARY = 3,
        LC_NUMERIC  = 4,
        LC_TIME     = 5,
    }

    private struct _xlocale;

    ///
    alias locale_t = _xlocale*;

    version (NetBSD)
        enum LC_ALL_MASK = (cast(int)~0);
    else
        enum LC_ALL_MASK = (
            LC_COLLATE_MASK | LC_CTYPE_MASK | LC_MESSAGES_MASK |
            LC_MONETARY_MASK | LC_NUMERIC_MASK | LC_TIME_MASK);


    ///
    enum
    {
        LC_COLLATE_MASK  = (1 << 0),
        LC_CTYPE_MASK    = (1 << 1),
        LC_MESSAGES_MASK = (1 << 2),
        LC_MONETARY_MASK = (1 << 3),
        LC_NUMERIC_MASK  = (1 << 4),
        LC_TIME_MASK     = (1 << 5),
    }

    ///
    enum LC_GLOBAL_LOCALE = (cast(locale_t)-1);

    static locale_t __current_locale()
    {
        locale_t __locale = cast(locale_t)pthread_getspecific(__locale_key);
        return (__locale ? __locale : &__global_locale);
    }
}

version (Linux_Musl)
{
    ///
    enum
    {
        LC_ALL      = 6,
        LC_COLLATE  = 3,
        LC_CTYPE    = 0,
        LC_MESSAGES = 5,
        LC_MONETARY = 4,
        LC_NUMERIC  = 1,
        LC_TIME     = 2,

        // Linux-specific
        LC_PAPER          =  7,
        LC_NAME           =  8,
        LC_ADDRESS        =  9,
        LC_TELEPHONE      = 10,
        LC_MEASUREMENT    = 11,
        LC_IDENTIFICATION = 12,
    }

    ///
    enum
    {
        LC_ALL_MASK = (LC_CTYPE_MASK | LC_NUMERIC_MASK | LC_TIME_MASK |
                       LC_COLLATE_MASK | LC_MONETARY_MASK | LC_MESSAGES_MASK |
                       LC_PAPER_MASK | LC_NAME_MASK | LC_ADDRESS_MASK |
                       LC_TELEPHONE_MASK | LC_MEASUREMENT_MASK |
                       LC_IDENTIFICATION_MASK),

        LC_COLLATE_MASK  = (1 << LC_COLLATE),
        LC_CTYPE_MASK    = (1 << LC_CTYPE),
        LC_MESSAGES_MASK = (1 << LC_MESSAGES),
        LC_MONETARY_MASK = (1 << LC_MONETARY),
        LC_NUMERIC_MASK  = (1 << LC_NUMERIC),
        LC_TIME_MASK     = (1 << LC_TIME),

        // Linux specific
        LC_PAPER_MASK          = (1 << LC_PAPER),
        LC_NAME_MASK           = (1 << LC_NAME),
        LC_ADDRESS_MASK        = (1 << LC_ADDRESS),
        LC_TELEPHONE_MASK      = (1 << LC_TELEPHONE),
        LC_MEASUREMENT_MASK    = (1 << LC_MEASUREMENT),
        LC_IDENTIFICATION_MASK = (1 << LC_IDENTIFICATION),
    }

    enum LOCALE_NAME_MAX = 23;

    private struct __locale_map {
	    const void *map;
	    size_t map_size;
	    char[LOCALE_NAME_MAX+1] name;
	    const __locale_map *next;
    };

    struct __locale_struct {
	    const __locale_map*[6] cat;
    };


    ///
    alias locale_t = __locale_struct*;

    ///
    enum LC_GLOBAL_LOCALE = (cast(locale_t)-1);

    __gshared shared(__locale_struct*) CURRENT_LOCALE;

    shared(__locale_struct) __c_locale = {};
    alias C_LOCALE = __c_locale;

    //__gshared shared uint32_t[5] empty_mo = [ 0x950412de, 0, -1, -1, -1 ];
    __gshared shared(__locale_map) __c_dot_utf8 = {
	    //map: empty_mo,
	    //map_size: empty_mo.sizeof,
	    name: "C.UTF-8"
    };
    shared(__locale_struct) __c_dot_utf8_locale = {
	    cat: [LC_CTYPE: &__c_dot_utf8]
    };
    alias UTF8_LOCALE = __c_dot_utf8_locale;
}
