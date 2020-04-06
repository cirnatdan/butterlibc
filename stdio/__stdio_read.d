module stdio.__stdio_read;

import stdio;
import posix.sys.uio;
import sys.linux.syscalls;

extern(C):
nothrow:
@nogc:
size_t __stdio_read(FILE *f, ubyte *buf, size_t len)
{
	iovec[2] iov = [
		{ iov_base: buf, iov_len: len - !!f.buf_size },
		{ iov_base: cast(void*)f.buf, iov_len: f.buf_size }
	];
	ssize_t cnt;

	cnt = iov[0].iov_len ? syscall(SYS.readv, f.fd, cast(int)&iov, 2)
		: syscall(SYS.read, f.fd, cast(int)iov[1].iov_base, cast(int)iov[1].iov_len);
	if (cnt <= 0) {
	    auto flags = cnt ? f.flags | F_ERR : f.flags | F_EOF;
		f.flags = flags;
		return 0;
	}
	if (cnt <= iov[0].iov_len) return cnt;
	cnt -= iov[0].iov_len;
	f.rpos = f.buf;
	f.rend = f.buf + cnt;
	if (f.buf_size) {
	    *f.rpos = cast(ubyte)(*f.rpos + 1);
	    buf[len-1] = *f.rpos;
    }
	return len;
}
