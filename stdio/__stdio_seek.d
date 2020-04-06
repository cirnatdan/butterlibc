module stdio.__stdio_seek;

import stdio;
import posix.unistd;

extern(C):
off_t __stdio_seek(FILE *f, off_t off, int whence)
{
	return lseek(f.fd, off, whence);
}

