module stdio.stdout;

import stdio;
import stdio.__stdout_write;
import stdio.__stdio_seek;
import stdio.__stdio_close;

extern(C):
static __gshared ubyte[BUFSIZ+UNGET] buf;
FILE __stdout_FILE = {
	buf: cast(shared ubyte*)buf+UNGET,
	buf_size: (&buf-UNGET).sizeof,
	fd: 1,
	flags: F_PERM | F_NORD,
	lbf: '\n',
	write: &__stdout_write,
	seek: &__stdio_seek,
	close: &__stdio_close,
	lock: -1,
};
__gshared FILE* stdout = &__stdout_FILE;
FILE* __stdout_used = &__stdout_FILE;
