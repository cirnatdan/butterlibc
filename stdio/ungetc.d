module stdio.ungetc;

import stdio;

extern(C):

int ungetc(int c, FILE *f)
{
	if (c == EOF) return c;

	//FLOCK(f);

	if (!f.rpos) __toread(f);
	if (!f.rpos || f.rpos <= f.buf - UNGET) {
		//FUNLOCK(f);
		return EOF;
	}

    f.rpos = f.rpos - 1;
	*f.rpos = cast(ubyte)c;
	auto flags = f.flags & ~F_EOF;
	f.flags = flags;

	//FUNLOCK(f);
	return cast(ubyte)c;
}
