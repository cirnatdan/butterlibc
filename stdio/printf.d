/////////////////////////////////////////////////////////////////////////////
// \author (c) Marco Paland (info@paland.com)
//             2014-2019, PALANDesign Hannover, Germany
//
// \license The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// \brief Tiny printf, sprintf and (v)snprintf implementation, optimized for speed on
//        embedded systems with a very limited resources. These routines are thread
//        safe and reentrant!
//        Use this instead of the bloated standard/newlib printf cause these use
//        malloc for printf (and may not be thread safe).//
///////////////////////////////////////////////////////////////////////////////

import stdarg;
import stdint;

extern (C):
@system:
@nogc:

extern (C) void putchar() {}

// To use in no-dependency printf
void _putchar(char* character) {
    version(AArch64) {
        import ldc.llvmasm;
        __asm(`svc     #0`,
         "{x0},{x1},{x2},{x8}", 1, character, 1, 64);
    } else version(X86_64) {
        asm @nogc{
            mov     RAX, 0x2000004;
            mov     RDI, 1;
            mov     RSI, character;
            mov     RDX, 1;
            syscall;
        }
    }
}

extern(C) alias putchar = _putchar;

// 'ntoa' conversion buffer size, this must be big enough to hold one converted
// numeric number including padded zeros (dynamically created on stack)
// default: 32 byte
enum PRINTF_NTOA_BUFFER_SIZE = 32;

// 'ftoa' conversion buffer size, this must be big enough to hold one converted
// float number including padded zeros (dynamically created on stack)
// default: 32 byte
enum PRINTF_FTOA_BUFFER_SIZE = 32;

// support for the floating point type (%f)
// default: activated
enum PRINTF_SUPPORT_FLOAT = true;

// support for exponential floating point notation (%e/%g)
// default: activated
enum PRINTF_SUPPORT_EXPONENTIAL = true;

// define the default floating point precision
// default: 6 digits
enum PRINTF_DEFAULT_FLOAT_PRECISION = 6;

// define the largest float suitable to print with %f
// default: 1e9
enum PRINTF_MAX_FLOAT = 1e9;

// support for the long long types (%llu or %p)
// default: activated
enum PRINTF_SUPPORT_LONG_LONG = true;

// support for the ptrdiff_t type (%t)
// ptrdiff_t is normally defined in <stddef.h> as long or long long type
// default: activated
enum PRINTF_SUPPORT_PTRDIFF_T = true;

///////////////////////////////////////////////////////////////////////////////

// internal flag definitions
enum FLAGS_ZEROPAD   = 1 <<  0;
enum FLAGS_LEFT      = 1 <<  1;
enum FLAGS_PLUS      = 1 <<  2;
enum FLAGS_SPACE     = 1 <<  3;
enum FLAGS_HASH      = 1 <<  4;
enum FLAGS_UPPERCASE = 1 <<  5;
enum FLAGS_CHAR      = 1 <<  6;
enum FLAGS_SHORT     = 1 <<  7;
enum FLAGS_LONG      = 1 <<  8;
enum FLAGS_LONG_LONG = 1 <<  9;
enum FLAGS_PRECISION = 1 << 10;
enum FLAGS_ADAPT_EXP = 1 << 11;


// import float.h for DBL_MAX
static if (PRINTF_SUPPORT_FLOAT) {
  import float_;
}


// output function type
alias out_fct_type = void function(char character, void *buffer, size_t idx, size_t maxlen);

// wrapper (used as buffer) for output function type
struct out_fct_wrap_type {
  @nogc void function(char character, void* arg) fct;
  void *arg;
};


// internal buffer output]
pragma(inline):
static void _out_buffer(char character, void* buffer, size_t idx, size_t maxlen)
{
  if (idx < maxlen) {
    (cast(char*)buffer)[idx] = character;
  }
}


// internal null output
pragma(inline):
static void _out_null(char character, void* buffer, size_t idx, size_t maxlen)
{
  cast(void)character; cast(void)buffer; cast(void)idx; cast(void)maxlen;
}


// internal _putchar wrapper
pragma(inline):
static void _out_char(char character, void* buffer, size_t idx, size_t maxlen)
{
  cast(void)buffer; cast(void)idx; cast(void)maxlen;
  if (character) {
    _putchar(&character);
  }
}

// internal output function wrapper
pragma(inline):
static void _out_fct(char character, void* buffer, size_t idx, size_t maxlen)
{
  cast(void)idx; cast(void)maxlen;
  if (character) {
    // buffer is the output fct pointer
    (cast(out_fct_wrap_type*)buffer).fct(character, (cast(out_fct_wrap_type*)buffer).arg);
  }
}


// internal secure strlen
// \return The length of the string (excluding the terminating 0) limited by 'maxsize'
pragma(inline):
static uint _strnlen_s(const char* str, size_t maxsize)
{
  const(char)* s;
  for (s = str; *s && maxsize--; ++s){}
  return cast(uint)(s - str);
}


// internal test if char is a digit (0-9)
// \return true if char is a digit
pragma(inline):
static bool _is_digit(char ch)
{
  return (ch >= '0') && (ch <= '9');
}


// internal ASCII string to uint conversion
static uint _atoi(const(char)** str)
{
  uint i = 0U;
  while (_is_digit(**str)) {
    i = i * 10U + cast(uint)(*((*str)++) - '0');
  }
  return i;
}


// output the specified string in reverse, taking care of any zero-padding
static size_t _out_rev(out_fct_type out_fct, char* buffer, size_t idx, size_t maxlen, const char* buf, size_t len, uint width, uint flags)
{
  const size_t start_idx = idx;

  // pad spaces up to given width
  if (!(flags & FLAGS_LEFT) && !(flags & FLAGS_ZEROPAD)) {
    for (size_t i = len; i < width; i++) {
      out_fct(' ', buffer, idx++, maxlen);
    }
  }

  // reverse string
  while (len) {
    out_fct(buf[--len], buffer, idx++, maxlen);
  }

  // append pad spaces up to given width
  if (flags & FLAGS_LEFT) {
    while (idx - start_idx < width) {
      out_fct(' ', buffer, idx++, maxlen);
    }
  }

  return idx;
}


// internal itoa format
static size_t _ntoa_format(out_fct_type out_fct, char* buffer, size_t idx, size_t maxlen, char* buf, size_t len, bool negative, uint base, uint prec, uint width, uint flags)
{
  // pad leading zeros
  if (!(flags & FLAGS_LEFT)) {
    if (width && (flags & FLAGS_ZEROPAD) && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
      width--;
    }
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = '0';
    }
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = '0';
    }
  }

  // handle hash
  if (flags & FLAGS_HASH) {
    if (!(flags & FLAGS_PRECISION) && len && ((len == prec) || (len == width))) {
      len--;
      if (len && (base == 16U)) {
        len--;
      }
    }
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = 'x';
    }
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = 'X';
    }
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = 'b';
    }
    if (len < PRINTF_NTOA_BUFFER_SIZE) {
      buf[len++] = '0';
    }
  }

  if (len < PRINTF_NTOA_BUFFER_SIZE) {
    if (negative) {
      buf[len++] = '-';
    }
    else if (flags & FLAGS_PLUS) {
      buf[len++] = '+';  // ignore the space if the '+' exists
    }
    else if (flags & FLAGS_SPACE) {
      buf[len++] = ' ';
    }
  }

  return _out_rev(out_fct, buffer, idx, maxlen, buf, len, width, flags);
}


// internal itoa for 'long' type
static size_t _ntoa_long(out_fct_type out_fct, char* buffer, size_t idx, size_t maxlen, ulong value, bool negative, ulong base, uint prec, uint width, uint flags)
{
  char[PRINTF_NTOA_BUFFER_SIZE] buf;
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    flags &= ~FLAGS_HASH;
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    do {
      const char digit = cast(char)(value % base);
      buf[len++] = cast(char)(digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10);
      value /= base;
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
  }

  return _ntoa_format(out_fct, buffer, idx, maxlen, cast(char*)buf, len, negative, cast(uint)base, prec, width, flags);
}


// internal itoa for 'long long' type
static if (PRINTF_SUPPORT_LONG_LONG):
static size_t _ntoa_long_long(out_fct_type out_fct, char* buffer, size_t idx, size_t maxlen, ulong value, bool negative, ulong base, uint prec, uint width, uint flags)
{
  char[PRINTF_NTOA_BUFFER_SIZE] buf;
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    flags &= ~FLAGS_HASH;
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    do {
      const char digit = cast(char)(value % base);
      buf[len++] = cast(char)(digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10);
      value /= base;
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
  }

  return _ntoa_format(out_fct, buffer, idx, maxlen, cast(char*)buf, len, negative, cast(uint)base, prec, width, flags);
}


static if (PRINTF_SUPPORT_FLOAT) {

static if (PRINTF_SUPPORT_EXPONENTIAL) {
// forward declaration so that _ftoa can switch to exp notation for values > PRINTF_MAX_FLOAT
static size_t _etoa(out_fct_type out_fct, char* buffer, size_t idx, size_t maxlen, double value, uint prec, uint width, uint flags);
}


// internal ftoa for fixed decimal floating point
static size_t _ftoa(out_fct_type out_fct, char* buffer, size_t idx, size_t maxlen, double value, uint prec, uint width, uint flags)
{
  char[PRINTF_FTOA_BUFFER_SIZE] buf;
  size_t len  = 0U;
  double diff = 0.0;

  // powers of 10
  static const double[] pow10 = [ 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000 ];

  // test for special values
  if (value != value)
    return _out_rev(out_fct, buffer, idx, maxlen, "nan", 3, width, flags);
  if (value < -DBL_MAX)
    return _out_rev(out_fct, buffer, idx, maxlen, "fni-", 4, width, flags);
  if (value > DBL_MAX)
    return _out_rev(out_fct, buffer, idx, maxlen, (flags & FLAGS_PLUS) ? "fni+" : "fni", (flags & FLAGS_PLUS) ? 4U : 3U, width, flags);

  // test for very large values
  // standard printf behavior is to print EVERY whole number digit -- which could be 100s of characters overflowing your buffers == bad
  if ((value > PRINTF_MAX_FLOAT) || (value < -PRINTF_MAX_FLOAT)) {
static if (PRINTF_SUPPORT_EXPONENTIAL) {
    return _etoa(out_fct, buffer, idx, maxlen, value, prec, width, flags);
} else {
    return 0U;
}
  }

  // test for negative
  bool negative = false;
  if (value < 0) {
    negative = true;
    value = 0 - value;
  }

  // set default precision, if not set explicitly
  if (!(flags & FLAGS_PRECISION)) {
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
  }
  // limit precision to 9, cause a prec >= 10 can lead to overflow errors
  while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
    buf[len++] = '0';
    prec--;
  }

  int whole = cast(int)value;
  double tmp = (value - whole) * pow10[prec];
  uint frac = cast(uint)tmp;
  diff = tmp - frac;

  if (diff > 0.5) {
    ++frac;
    // handle rollover, e.g. case 0.99 with prec 1 is 1.0
    if (frac >= pow10[prec]) {
      frac = 0;
      ++whole;
    }
  }
  else if (diff < 0.5) {
  }
  else if ((frac == 0U) || (frac & 1U)) {
    // if halfway, round up if odd OR if last digit is 0
    ++frac;
  }

  if (prec == 0U) {
    diff = value - cast(double)whole;
    if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
      // exactly 0.5 and ODD, then round up
      // 1.5 -> 2, but 2.5 -> 2
      ++whole;
    }
  }
  else {
    uint count = prec;
    // now do fractional part, as an unsigned number
    while (len < PRINTF_FTOA_BUFFER_SIZE) {
      --count;
      buf[len++] = cast(char)(48U + (frac % 10U));
      if (!(frac /= 10U)) {
        break;
      }
    }
    // add extra 0s
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
      buf[len++] = '0';
    }
    if (len < PRINTF_FTOA_BUFFER_SIZE) {
      // add decimal
      buf[len++] = '.';
    }
  }

  // do whole part, number is reversed
  while (len < PRINTF_FTOA_BUFFER_SIZE) {
    buf[len++] = cast(char)(48 + (whole % 10));
    if (!(whole /= 10)) {
      break;
    }
  }

  // pad leading zeros
  if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
    if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
      width--;
    }
    while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
      buf[len++] = '0';
    }
  }

  if (len < PRINTF_FTOA_BUFFER_SIZE) {
    if (negative) {
      buf[len++] = '-';
    }
    else if (flags & FLAGS_PLUS) {
      buf[len++] = '+';  // ignore the space if the '+' exists
    }
    else if (flags & FLAGS_SPACE) {
      buf[len++] = ' ';
    }
  }

  return _out_rev(out_fct, buffer, idx, maxlen, cast(char*)buf, len, width, flags);
}


static if (PRINTF_SUPPORT_EXPONENTIAL) {
// internal ftoa variant for exponential floating-point type, contributed by Martijn Jasperse <m.jasperse@gmail.com>
static size_t _etoa(out_fct_type out_fct, char* buffer, size_t idx, size_t maxlen, double value, uint prec, uint width, uint flags)
{
  // check for NaN and special values
  if ((value != value) || (value > DBL_MAX) || (value < -DBL_MAX)) {
    return _ftoa(out_fct, buffer, idx, maxlen, value, prec, width, flags);
  }

  // determine the sign
  const bool negative = value < 0;
  if (negative) {
    value = -value;
  }

  // default precision
  if (!(flags & FLAGS_PRECISION)) {
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
  }

  // determine the decimal exponent
  // based on the algorithm by David Gay (https://www.ampl.com/netlib/fp/dtoa.c)
  union conv_union {
    uint64_t U;
    double   F;
  }

  conv_union conv;
  conv.F = value;
  int exp2 = cast(int)((conv.U >> 52U) & 0x07FFU) - 1023;           // effectively log2
  conv.U = (conv.U & ((1UL << 52U) - 1U)) | (1023UL << 52U);  // drop the exponent so conv.F is now in [1,2)
  // now approximate log10 from the log2 integer part and an expansion of ln around 1.5
  int expval = cast(int)(0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
  // now we want to compute 10^expval but we want to be sure it won't overflow
  exp2 = cast(int)(expval * 3.321928094887362 + 0.5);
  const double z  = expval * 2.302585092994046 - exp2 * 0.6931471805599453;
  const double z2 = z * z;
  conv.U = cast(uint64_t)(exp2 + 1023) << 52U;
  // compute exp(z) using continued fractions, see https://en.wikipedia.org/wiki/Exponential_function#Continued_fractions_for_ex
  conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
  // correct for rounding errors
  if (value < conv.F) {
    expval--;
    conv.F /= 10;
  }

  // the exponent format is "%+03d" and largest value is "307", so set aside 4-5 characters
  uint minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;

  // in "%g" mode, "prec" is the number of *significant figures* not decimals
  if (flags & FLAGS_ADAPT_EXP) {
    // do we want to fall-back to "%f" mode?
    if ((value >= 1e-4) && (value < 1e6)) {
      if (cast(int)prec > expval) {
        prec = cast(uint)(cast(int)prec - expval - 1);
      }
      else {
        prec = 0;
      }
      flags |= FLAGS_PRECISION;   // make sure _ftoa respects precision
      // no characters in exponent
      minwidth = 0U;
      expval   = 0;
    }
    else {
      // we use one sigfig for the whole part
      if ((prec > 0) && (flags & FLAGS_PRECISION)) {
        --prec;
      }
    }
  }

  // will everything fit?
  uint fwidth = width;
  if (width > minwidth) {
    // we didn't fall-back so subtract the characters required for the exponent
    fwidth -= minwidth;
  } else {
    // not enough characters, so go back to default sizing
    fwidth = 0U;
  }
  if ((flags & FLAGS_LEFT) && minwidth) {
    // if we're padding on the right, DON'T pad the floating part
    fwidth = 0U;
  }

  // rescale the float value
  if (expval) {
    value /= conv.F;
  }

  // output the floating part
  const size_t start_idx = idx;
  idx = _ftoa(out_fct, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);

  // output the exponent part
  if (minwidth) {
    // output the exponential symbol
    out_fct((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    // output the exponent value
    idx = _ntoa_long(out_fct, buffer, idx, maxlen, (expval < 0) ? -expval : expval, expval < 0, 10, 0, minwidth-1, FLAGS_ZEROPAD | FLAGS_PLUS);
    // might need to right-pad spaces
    if (flags & FLAGS_LEFT) {
      while (idx - start_idx < width) out_fct(' ', buffer, idx++, maxlen);
    }
  }
  return idx;
}
}  // PRINTF_SUPPORT_EXPONENTIAL
}  // PRINTF_SUPPORT_FLOAT


// internal vsnprintf
static int _vsnprintf(out_fct_type out_fct, char* buffer, const size_t maxlen, const(char)* format, va_list va)
{
  uint flags, width, precision, n;
  size_t idx = 0U;

  if (!buffer) {
    // use null output function
    out_fct = &_out_null;
  }

  while (*format)
  {
    // format specifier?  %[flags][width][.precision][length]
    if (*format != '%') {
      // no
      out_fct(*format, buffer, idx++, maxlen);
      format++;
      continue;
    }
    else {
      // yes, evaluate it
      format++;
    }

    // evaluate flags
    flags = 0U;
    do {
      switch (*format) {
        case '0': flags |= FLAGS_ZEROPAD; format++; n = 1U; break;
        case '-': flags |= FLAGS_LEFT;    format++; n = 1U; break;
        case '+': flags |= FLAGS_PLUS;    format++; n = 1U; break;
        case ' ': flags |= FLAGS_SPACE;   format++; n = 1U; break;
        case '#': flags |= FLAGS_HASH;    format++; n = 1U; break;
        default :                                   n = 0U; break;
      }
    } while (n);

    // evaluate width field
    width = 0U;
    if (_is_digit(*format)) {
      width = _atoi(&format);
    }
    else if (*format == '*') {
      int w;
      va_arg(va, w);
      if (w < 0) {
        flags |= FLAGS_LEFT;    // reverse padding
        width = cast(uint)-w;
      }
      else {
        width = cast(uint)w;
      }
      format++;
    }

    // evaluate precision field
    precision = 0U;
    if (*format == '.') {
      flags |= FLAGS_PRECISION;
      format++;
      if (_is_digit(*format)) {
        precision = _atoi(&format);
      }
      else if (*format == '*') {
        int prec;
        va_arg(va, prec);
        precision = prec > 0 ? cast(uint)prec : 0U;
        format++;
      }
    }

    // evaluate length field
    switch (*format) {
      case 'l' :
        flags |= FLAGS_LONG;
        format++;
        if (*format == 'l') {
          flags |= FLAGS_LONG_LONG;
          format++;
        }
        break;
      case 'h' :
        flags |= FLAGS_SHORT;
        format++;
        if (*format == 'h') {
          flags |= FLAGS_CHAR;
          format++;
        }
        break;
static if (PRINTF_SUPPORT_PTRDIFF_T) {
      case 't' :
        flags |= (ptrdiff_t.sizeof == long.sizeof ? FLAGS_LONG : FLAGS_LONG_LONG);
        format++;
        break;
}
      case 'j' :
        flags |= (intmax_t.sizeof == long.sizeof ? FLAGS_LONG : FLAGS_LONG_LONG);
        format++;
        break;
      case 'z' :
        flags |= (size_t.sizeof == long.sizeof ? FLAGS_LONG : FLAGS_LONG_LONG);
        format++;
        break;
      default :
        break;
    }

    // evaluate specifier
    switch (*format) {
      case 'd' :
      case 'i' :
      case 'u' :
      case 'x' :
      case 'X' :
      case 'o' :
      case 'b' : {
        // set the base
        uint base;
        if (*format == 'x' || *format == 'X') {
          base = 16U;
        }
        else if (*format == 'o') {
          base =  8U;
        }
        else if (*format == 'b') {
          base =  2U;
        }
        else {
          base = 10U;
          flags &= ~FLAGS_HASH;   // no hash for dec format
        }
        // uppercase
        if (*format == 'X') {
          flags |= FLAGS_UPPERCASE;
        }

        // no plus or space flag for u, x, X, o, b
        if ((*format != 'i') && (*format != 'd')) {
          flags &= ~(FLAGS_PLUS | FLAGS_SPACE);
        }

        // ignore '0' flag when precision is given
        if (flags & FLAGS_PRECISION) {
          flags &= ~FLAGS_ZEROPAD;
        }

        // convert the integer
        if ((*format == 'i') || (*format == 'd')) {
          // signed
          if (flags & FLAGS_LONG_LONG) {
static if (PRINTF_SUPPORT_LONG_LONG) {
            long value;
            va_arg(va, value);
            idx = _ntoa_long_long(out_fct, buffer, idx, maxlen, cast(ulong)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
}
          }
          else if (flags & FLAGS_LONG) {
            long value;
            va_arg(va, value);
            idx = _ntoa_long(out_fct, buffer, idx, maxlen, cast(uint)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
          }
          else {
            int v;
            va_arg(va, v);
            auto value = (flags & FLAGS_CHAR) ? cast(char)v : (flags & FLAGS_SHORT) ? cast(short)v : v;
            idx = _ntoa_long(out_fct, buffer, idx, maxlen, cast(uint)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
          }
        }
        else {
          // unsigned
          if (flags & FLAGS_LONG_LONG) {
static if (PRINTF_SUPPORT_LONG_LONG) {
            ulong value;
            va_arg(va, value);
            idx = _ntoa_long_long(out_fct, buffer, idx, maxlen, value, false, base, precision, width, flags);
}
          }
          else if (flags & FLAGS_LONG) {
            uint value;
            va_arg(va, value);
            idx = _ntoa_long(out_fct, buffer, idx, maxlen, value, false, base, precision, width, flags);
          }
          else {
            uint v;
            va_arg(va, v);
            auto value = (flags & FLAGS_CHAR) ? cast(ubyte)v : (flags & FLAGS_SHORT) ? cast(ushort)v : v;
            idx = _ntoa_long(out_fct, buffer, idx, maxlen, value, false, base, precision, width, flags);
          }
        }
        format++;
        break;
      }
static if (PRINTF_SUPPORT_FLOAT) {
      case 'f' :
      case 'F' :
        {if (*format == 'F') flags |= FLAGS_UPPERCASE;
        double value;
        va_arg(va, value);
        idx = _ftoa(out_fct, buffer, idx, maxlen, value, precision, width, flags);
        format++;}
        break;
static if (PRINTF_SUPPORT_EXPONENTIAL) {
      case 'e':
      case 'E':
      case 'g':
      case 'G':
        if ((*format == 'g')||(*format == 'G')) flags |= FLAGS_ADAPT_EXP;
        if ((*format == 'E')||(*format == 'G')) flags |= FLAGS_UPPERCASE;
        double v;
        va_arg(va, v);
        idx = _etoa(out_fct, buffer, idx, maxlen, v, precision, width, flags);
        format++;
        break;
}  // PRINTF_SUPPORT_EXPONENTIAL
}  // PRINTF_SUPPORT_FLOAT
      case 'c' : {
        uint l = 1U;
        // pre padding
        if (!(flags & FLAGS_LEFT)) {
          while (l++ < width) {
            out_fct(' ', buffer, idx++, maxlen);
          }
        }
        // char output
        int value;
        va_arg(va, value);
        out_fct(cast(char)value, buffer, idx++, maxlen);
        // post padding
        if (flags & FLAGS_LEFT) {
          while (l++ < width) {
            out_fct(' ', buffer, idx++, maxlen);
          }
        }
        format++;
        break;
      }

      case 's' : {
        char* p;
        va_arg(va, p);
        uint l = _strnlen_s(p, precision ? precision : cast(size_t)-1);
        // pre padding
        if (flags & FLAGS_PRECISION) {
          l = (l < precision ? l : precision);
        }
        if (!(flags & FLAGS_LEFT)) {
          while (l++ < width) {
            out_fct(' ', buffer, idx++, maxlen);
          }
        }
        // string output
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
          out_fct(*(p++), buffer, idx++, maxlen);
        }
        // post padding
        if (flags & FLAGS_LEFT) {
          while (l++ < width) {
            out_fct(' ', buffer, idx++, maxlen);
          }
        }
        format++;
        break;
      }
//
static if (PRINTF_SUPPORT_LONG_LONG) {      
      case 'p' : {
        width = (void*).sizeof * 2U;
        flags |= FLAGS_ZEROPAD | FLAGS_UPPERCASE;
        const bool is_ll = uintptr_t.sizeof == long.sizeof;
        if (is_ll) {
          void* value;
          va_arg(va, value);
          idx = _ntoa_long_long(out_fct, buffer, idx, maxlen, cast(uintptr_t)value, false, 16U, precision, width, flags);
        }
        else {
          void* value;
          va_arg(va, value);
          idx = _ntoa_long(out_fct, buffer, idx, maxlen, cast(uint)(cast(uintptr_t)value), false, 16U, precision, width, flags);
        }
        format++;
        break;
      }
} else {
      case 'p' : {
        width = (void*).sizeof * 2U;
        flags |= FLAGS_ZEROPAD | FLAGS_UPPERCASE;
        void* value;
        va_arg(va, value);
        idx = _ntoa_long(out_fct, buffer, idx, maxlen, cast(uint)(cast(uintptr_t)value), false, 16U, precision, width, flags);
        format++;
        break;
      }
}
//

      case '%' :
        out_fct('%', buffer, idx++, maxlen);
        format++;
        break;

      default :
        out_fct(*format, buffer, idx++, maxlen);
        format++;
        break;
    }
  }

  // termination
  out_fct(cast(char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);

  // return written chars without terminating \0
  return cast(int)idx;
}


///////////////////////////////////////////////////////////////////////////////

extern(C) int printf(const char* format, ...)
{
  va_list va;
  va_start(va, format);
  char[1] buffer;
  const int ret = _vsnprintf(&_out_char, cast(char*)buffer, cast(size_t)-1, format, va);
  va_end(va);
  return ret;
}


int sprintf_(char* buffer, const char* format, va_list va)
{
  va_start(va, format);
  const int ret = _vsnprintf(&_out_buffer, buffer, cast(size_t)-1, format, va);
  va_end(va);
  return ret;
}


int snprintf_(char* buffer, size_t count, const char* format, va_list va)
{
  va_start(va, format);
  const int ret = _vsnprintf(&_out_buffer, buffer, count, format, va);
  va_end(va);
  return ret;
}


int vprintf_(const char* format, va_list va)
{
  char[1] buffer;
  return _vsnprintf(&_out_char, cast(char*)buffer, cast(size_t)-1, format, va);
}


int vsnprintf_(char* buffer, size_t count, const char* format, va_list va)
{
  return _vsnprintf(&_out_buffer, buffer, count, format, va);
}

alias out_fct_hack = @nogc void function(char character, void* arg);
int fctprintf(out_fct_hack out_fct, void* arg, const char* format, va_list va)
{
  va_start(va, format);
  const out_fct_wrap_type out_fct_wrap = { out_fct, arg };
  const int ret = _vsnprintf(&_out_fct, cast(char*)cast(uintptr_t)&out_fct_wrap, cast(size_t)-1, format, va);
  va_end(va);
  return ret;
}
