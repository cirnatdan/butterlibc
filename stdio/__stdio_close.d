module stdio.__stdio_close;

import stdio;
import sys.linux.syscalls;

extern(C):
static int __aio_close(int fd)
{
	return fd;
}


int __stdio_close(FILE *f)
{
	return cast(int)syscall(SYS.close, __aio_close(f.fd));
}

