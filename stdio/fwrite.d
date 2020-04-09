import stdio;
import stdio.__towrite;
import string;

extern (C):

size_t __fwritex(ubyte *s, size_t l, FILE *f)
{
    size_t i=0;

    if (!f.wend && __towrite(f)) return 0;

    if (l > f.wend - f.wpos) return f.write(f, s, l);

    if (f.lbf >= 0) {
	    /* Match /^(.*\n|)/ */
	    for (i=l; i && s[i-1] != '\n'; i--){}
	    if (i) {
		    size_t n = f.write(f, s, i);
		    if (n < i) return n;
		    s += i;
		    l -= i;
	    }
    }

    memcpy(cast(void*)f.wpos, cast(void*)s, l);
    auto wpos = f.wpos + l;
    f.wpos = wpos;
    return l+i;
}

//size_t fwrite(const void *src, size_t size, size_t nmemb, FILE *f)
//{
//	size_t k, l = size*nmemb;
//	if (!size) nmemb = 0;
//	FLOCK(f);
//	k = __fwritex(src, l, f);
//	FUNLOCK(f);
//	return k==l ? nmemb : k/size;
//}

// weak_alias(fwrite, fwrite_unlocked);
