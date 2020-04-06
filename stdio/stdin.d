module stdio.stdin;

import stdio;

import stdio.__stdio_seek;
import stdio.__stdio_close;
import stdio.__stdio_read;

extern(C):
static __gshared ubyte[BUFSIZ+UNGET] buf;
FILE __stdin_FILE = {
	buf: cast(shared ubyte*)buf+UNGET,
	buf_size: (&buf-UNGET).sizeof,
	fd: 0,
	flags: F_PERM | F_NOWR,
	read: &__stdio_read,
	seek: &__stdio_seek,
	close: &__stdio_close,
	lock: -1,
};
__gshared FILE* stdin = &__stdin_FILE;
FILE* __stdin_used = &__stdin_FILE;
