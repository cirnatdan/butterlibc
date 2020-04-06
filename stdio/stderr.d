module stdio.sterr;

import stdio;
import stdio.__stdio_write;
import stdio.__stdio_seek;
import stdio.__stdio_close;

extern(C):
static __gshared ubyte[UNGET] buf;
FILE __stderr_FILE = {
	buf: cast(shared ubyte*)buf+UNGET,
	buf_size: 0,
	fd: 2,
	flags: F_PERM | F_NORD,
	lbf: -1,
	write: &__stdio_write,
	seek: &__stdio_seek,
	close: &__stdio_close,
	lock: -1,
};
__gshared FILE* stderr = &__stderr_FILE;
FILE* __stderr_used = &__stderr_FILE;
