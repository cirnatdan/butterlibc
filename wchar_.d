/**
 * D header file for C99.
 *
 * $(C_HEADER_DESCRIPTION pubs.opengroup.org/onlinepubs/009695399/basedefs/_wchar.h.html, _wchar.h)
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Authors:   Sean Kelly
 * Source:    $(DRUNTIMESRC core/stdc/_wchar_.d)
 * Standards: ISO/IEC 9899:1999 (E)
 */

private import config;
private import stdarg; // for va_list
private import stdio;  // for FILE, not exposed per spec
public import stddef;  // for wchar_t
public import time;    // for tm
public import stdint;  // for WCHAR_MIN, WCHAR_MAX
import errno;
import stdlib;

extern (C):
@system:
nothrow:
@nogc:

version (CRuntime_Glibc)
{
    ///
    struct mbstate_t
    {
        int __count;
        union ___value
        {
            wint_t __wch = 0;
            char[4] __wchb;
        }
        ___value __value;
    }
}
else version (FreeBSD)
{
    ///
    union __mbstate_t // <sys/_types.h>
    {
        char[128]   _mbstate8 = 0;
        long        _mbstateL;
    }

    ///
    alias mbstate_t = __mbstate_t;
}
else version (NetBSD)
{
    ///
    union __mbstate_t
    {
        int64_t   __mbstateL;
        char[128] __mbstate8;
    }

    ///
    alias mbstate_t = __mbstate_t;
}
else version (OpenBSD)
{
    ///
    union __mbstate_t
    {
        char[128] __mbstate8 = 0;
        int64_t   __mbstateL;
    }

    ///
    alias mbstate_t = __mbstate_t;
}
else version (DragonFlyBSD)
{
    ///
    union __mbstate_t                   // <sys/stdint.h>
    {
        char[128]   _mbstate8 = 0;
        long        _mbstateL;
    }

    ///
    alias mbstate_t = __mbstate_t;
}
else version (Solaris)
{
    ///
    struct __mbstate_t
    {
        version (D_LP64)
        {
            long[4] __filler;
        }
        else
        {
            int[6] __filler;
        }
    }

    ///
    alias mbstate_t = __mbstate_t;
}
else version (CRuntime_UClibc)
{
    ///
    struct mbstate_t
    {
        wchar_t __mask = 0;
        wchar_t __wc = 0;
    }
}
else
{
    ///
    alias int mbstate_t;
}

///
alias wchar_t wint_t;

///
enum wchar_t WEOF = 0xFFFF;

///
int fwprintf(FILE* stream, const scope wchar_t* format, ...);
///
int fwscanf(FILE* stream, const scope wchar_t* format, ...);
///
int swprintf(wchar_t* s, size_t n, const scope wchar_t* format, ...);
///
int swscanf(const scope wchar_t* s, const scope wchar_t* format, ...);
///
int vfwprintf(FILE* stream, const scope wchar_t* format, va_list arg);
///
int vfwscanf(FILE* stream, const scope wchar_t* format, va_list arg);
///
int vswprintf(wchar_t* s, size_t n, const scope wchar_t* format, va_list arg);
///
int vswscanf(const scope wchar_t* s, const scope wchar_t* format, va_list arg);
///
int vwprintf(const scope wchar_t* format, va_list arg);
///
int vwscanf(const scope wchar_t* format, va_list arg);
///
int wprintf(const scope wchar_t* format, ...);
///
int wscanf(const scope wchar_t* format, ...);

// No unsafe pointer manipulation.
@trusted
{
    ///
    wint_t fgetwc(FILE* stream);
    ///
    wint_t fputwc(wchar_t c, FILE* stream);
}

///
wchar_t* fgetws(wchar_t* s, int n, FILE* stream);
///
int      fputws(const scope wchar_t* s, FILE* stream);

// No unsafe pointer manipulation.
extern (D) @trusted
{
    ///
    wint_t getwchar()                     { return fgetwc(stdin);     }
    ///
    wint_t putwchar(wchar_t c)            { return fputwc(c,stdout);  }
    ///
    wint_t getwc(FILE* stream)            { return fgetwc(stream);    }
    ///
    wint_t putwc(wchar_t c, FILE* stream) { return fputwc(c, stream); }
}

// No unsafe pointer manipulation.
@trusted
{
    ///
    wint_t ungetwc(wint_t c, FILE* stream);
    ///
    version (CRuntime_Microsoft)
    {
        // MSVC defines this as an inline function.
        int fwide(FILE* stream, int mode) { return mode; }
    }
    else
    {
        int    fwide(FILE* stream, int mode);
    }
}

///
double  wcstod(const scope wchar_t* nptr, wchar_t** endptr);
///
float   wcstof(const scope wchar_t* nptr, wchar_t** endptr);
///
real    wcstold(const scope wchar_t* nptr, wchar_t** endptr);
///
c_long  wcstol(const scope wchar_t* nptr, wchar_t** endptr, int base);
///
long    wcstoll(const scope wchar_t* nptr, wchar_t** endptr, int base);
///
c_ulong wcstoul(const scope wchar_t* nptr, wchar_t** endptr, int base);
///
ulong   wcstoull(const scope wchar_t* nptr, wchar_t** endptr, int base);

///
pure wchar_t* wcscpy(return wchar_t* s1, scope const wchar_t* s2);
///
pure wchar_t* wcsncpy(return wchar_t* s1, scope const wchar_t* s2, size_t n);
///
pure wchar_t* wcscat(return wchar_t* s1, scope const wchar_t* s2);
///
pure wchar_t* wcsncat(return wchar_t* s1, scope const wchar_t* s2, size_t n);
///
pure int wcscmp(scope const wchar_t* s1, scope const wchar_t* s2);
///
int      wcscoll(scope const wchar_t* s1, scope const wchar_t* s2);
///
pure int wcsncmp(scope const wchar_t* s1, scope const wchar_t* s2, size_t n);
///
size_t   wcsxfrm(scope wchar_t* s1, scope const wchar_t* s2, size_t n);
///
pure inout(wchar_t)* wcschr(return inout(wchar_t)* s, wchar_t c);
///
pure size_t wcscspn(scope const wchar_t* s1, scope const wchar_t* s2);
///
pure inout(wchar_t)* wcspbrk(return inout(wchar_t)* s1, scope const wchar_t* s2);
///
pure inout(wchar_t)* wcsrchr(return inout(wchar_t)* s, wchar_t c);
///
pure size_t wcsspn(scope const wchar_t* s1, scope const wchar_t* s2);
///
pure inout(wchar_t)* wcsstr(return inout(wchar_t)* s1, scope const wchar_t* s2);
///
wchar_t* wcstok(return wchar_t* s1, scope const wchar_t* s2, wchar_t** ptr);
///
pure size_t wcslen(scope const wchar_t* s);

///
pure wchar_t* wmemchr(return const wchar_t* s, wchar_t c, size_t n);
///
pure int      wmemcmp(scope const wchar_t* s1, scope const wchar_t* s2, size_t n);
///
pure wchar_t* wmemcpy(return wchar_t* s1, scope const wchar_t* s2, size_t n);
///
pure wchar_t* wmemmove(return wchar_t* s1, scope const wchar_t* s2, size_t n);
///
pure wchar_t* wmemset(return wchar_t* s, wchar_t c, size_t n);

///
size_t wcsftime(wchar_t* s, size_t maxsize, const scope wchar_t* format, const scope tm* timeptr);

version (Windows)
{
    ///
    wchar_t* _wasctime(tm*);      // non-standard
    ///
    wchar_t* _wctime(time_t*);    // non-standard
    ///
    wchar_t* _wstrdate(wchar_t*); // non-standard
    ///
    wchar_t* _wstrtime(wchar_t*); // non-standard
}

// No unsafe pointer manipulation.
@trusted
{
    ///
    wint_t btowc(int c);
    ///
    int    wctob(wint_t c);
}

///
int    mbsinit(const scope mbstate_t* ps);
///
size_t mbrlen(const scope char* s, size_t n, mbstate_t* ps);
///
//size_t mbrtowc(wchar_t* pwc, const scope char* s, size_t n, mbstate_t* ps);
///
size_t wcrtomb(char* s, wchar_t wc, mbstate_t* ps);
///
size_t mbsrtowcs(wchar_t* dst, const scope char** src, size_t len, mbstate_t* ps);
///
size_t wcsrtombs(char* dst, const scope wchar_t** src, size_t len, mbstate_t* ps);

uint32_t OOB(uint32_t c, uint32_t b) {
    return ((((b)>>3)-0x10)|(((b)>>3)+(cast(int32_t)(c)>>26))) & ~7;
}

uint32_t R(uint32_t a, uint32_t b) { return ( a == 0x80 ? 0x40u - b : 0u - a) << 23;}
uint32_t FAILSTATE() { return R(0x80,0x80); }
uint32_t C(uint32_t x) { return x = ( x < 2 ? -1 : (R(0x80,0xc0) | x) ); }
uint32_t D(uint32_t x) { return x = C(x+16); }
uint32_t E(uint32_t x) { return x = ( x == 0 ? R(0xa0,0xc0) :
                                          x == 0xd ? R(0x80,0xa0) :
                                          R(0x80,0xc0))
                                      | ( R(0x80,0xc0) >> 6 )
                                      | x; }
uint32_t F(uint32_t x) { return x = ( x >= 5 ? 0:
                                          x == 0 ? R(0x90,0xc0) :
                                          x == 4 ? R(0x80,0x90) :
                                          R(0x80,0xc0) )
                                      | ( R(0x80,0xc0) >> 6 )
                                      | ( R(0x80,0xc0) >> 12 )
                                      | x; }

const uint32_t[] bittab = [
	              C(0x2),C(0x3),C(0x4),C(0x5),C(0x6),C(0x7),
	C(0x8),C(0x9),C(0xa),C(0xb),C(0xc),C(0xd),C(0xe),C(0xf),
	D(0x0),D(0x1),D(0x2),D(0x3),D(0x4),D(0x5),D(0x6),D(0x7),
	D(0x8),D(0x9),D(0xa),D(0xb),D(0xc),D(0xd),D(0xe),D(0xf),
	E(0x0),E(0x1),E(0x2),E(0x3),E(0x4),E(0x5),E(0x6),E(0x7),
	E(0x8),E(0x9),E(0xa),E(0xb),E(0xc),E(0xd),E(0xe),E(0xf),
	F(0x0),F(0x1),F(0x2),F(0x3),F(0x4)
];



enum SA = 0xc2u;
enum SB = 0xf5u;
/*
 * musl
 * This code was written by Rich Felker in 2010; no copyright is claimed.
 * This code is in the public domain. Attribution is appreciated but
 * unnecessary.
 */
size_t mbrtowc(wchar_t *wc, const char *src, size_t n, mbstate_t *st)
{
	static uint internal_state;
	uint c;
    ubyte *s = cast(ubyte *)src;
	const ulong N = n;

	if (!st) st = cast(mbstate_t *)&internal_state;
	c = *cast(uint *)st;

	if (!s) {
		s = cast(ubyte *)"";
		wc = cast(dchar *)&wc;
		n = 1;
	} else if (!wc) wc = cast(dchar *)&wc;

	if (!n) return -2;
	if (!c) {
		if (*s < 0x80) {
            *wc = *s;
		    return !!*wc;
	    }
		if (*s-SA > SB-SA) goto ilseq;
		c = bittab[*s++-SA]; n--;
	}

	if (n) {
		if (OOB(c,*s)) goto ilseq;
loop:
		c = c<<6 | *s++-0x80; n--;
		if (!(c&(1U<<31))) {
			*cast(uint *)st = 0;
			*wc = c;
			return N-n;
		}
		if (n) {
			if (*s-0x80u >= 0x40) goto ilseq;
			goto loop;
		}
	}

	*cast(uint *)st = c;
	return -2;
ilseq:
	*cast(uint *)st = FAILSTATE;
	errno.errno(EILSEQ);
	return -1;
}

int wctomb(char* s, wchar_t wc)
{
    if (!s) return 0;
    return cast(int)wcrtomb(s, wc, cast(mbstate_t*)(0));
}

bool IS_CODEUNIT(dchar c)
{
    return cast(uint)c - 0xdf80 < 0x80;
}

size_t wcrtomb(char* s, wchar_t wc, mbstate_t* st)
{
	if (!s) return 1;
	if (cast(char)wc < 0x80) {
		*s = cast(char)wc;
		return 1;
	} else if (MB_CUR_MAX == 1) {
		if (!IS_CODEUNIT(wc)) {
			errno.errno(EILSEQ);
			return -1;
		}
		*s = cast(char)wc;
		return 1;
	} else if (cast(char)wc < 0x800) {
		*s++ = cast(char)(0xc0 | (wc>>6));
		*s = 0x80 | (wc&0x3f);
		return 2;
	} else if (cast(char)wc < 0xd800 || (cast(char)wc-0xe000 < 0x2000)) {
		*s++ = cast(char)(0xe0 | (wc>>12));
		*s++ = 0x80 | ((wc>>6)&0x3f);
		*s = 0x80 | (wc&0x3f);
		return 3;
	} else if (cast(char)wc-0x10000 < 0x100000) {
		*s++ = 0xf0 | (wc>>18);
		*s++ = 0x80 | ((wc>>12)&0x3f);
		*s++ = 0x80 | ((wc>>6)&0x3f);
		*s = 0x80 | (wc&0x3f);
		return 4;
	}
	errno.errno(EILSEQ);
	return -1;
}

