module stdio.fputwc;

import wchar_;
import stdio;
import limits;
import posix.locale;
import ctype;
import fwrite;

extern(C):
wint_t __fputwc_unlocked(wchar_t c, FILE *f)
{
	char[MB_LEN_MAX] mbc;
	int l;
	shared locale_t *ploc = &CURRENT_LOCALE;
	shared locale_t loc = *ploc;

	if (f.mode <= 0) fwide(f, 1);
	*ploc = f.locale;

	if (isascii(c)) {
		c = putc_unlocked(c, f);
	} else if (f.wpos + MB_LEN_MAX < f.wend) {
		l = wctomb(cast(char *)f.wpos, c);
		if (l < 0) c = WEOF;
		else {
		    auto wpos = f.wpos + l;
		    f.wpos = wpos;
		}
	} else {
		l = wctomb(cast(char*)mbc, c);
		if (l < 0 || __fwritex(cast(ubyte *)mbc, l, f) < l) c = WEOF;
	}
	if (c==WEOF) {
	    auto flags = f.flags | F_ERR;
	    f.flags = flags;
	}
	*ploc = loc;
	return c;
}

wint_t fputwc(wchar_t c, FILE *f)
{
	//FLOCK(f);
	c = __fputwc_unlocked(c, f);
	//FUNLOCK(f);
	return c;
}
