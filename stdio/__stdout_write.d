module stdio.__stdout_write;

import stdio;

import posix.sys.ioctl;
import sys.linux.syscalls;
import stdio.__stdio_write;

extern(C):
@nogc:
@system:
nothrow:
size_t __stdout_write(FILE *f, const ubyte *buf, size_t len)
{
	winsize wsz;
	f.write = &__stdio_write;
	if (!(f.flags & F_SVB) && __syscall(SYS.ioctl, f.fd, TIOCGWINSZ, cast(int)&wsz))
		f.lbf = -1;
	return __stdio_write(f, buf, len);
}
