module stdio.__stdio_write;

import stdio;
import posix.sys.uio;
import sys.linux.syscalls;

extern(C):
nothrow:
@nogc:
size_t __stdio_write(FILE *f, const ubyte *buf, size_t len)
{
	iovec[2] iovs = [
		{ iov_base: cast(void*)f.wbase, iov_len: f.wpos-f.wbase },
		{ iov_base: cast(void*)buf, iov_len: len }
	];
	iovec *iov = cast(iovec*)iovs;
	size_t rem = iov[0].iov_len + iov[1].iov_len;
	int iovcnt = 2;
	ssize_t cnt;
	for (;;) {
		cnt = syscall(SYS.writev, f.fd, cast(int)iov, iovcnt);
		if (cnt == rem) {
			f.wend = f.buf + f.buf_size;
			f.wpos = f.wbase = f.buf;
			return len;
		}
		if (cnt < 0) {
			f.wpos = f.wbase = f.wend = cast(ubyte*)0;
			auto flags = f.flags | F_ERR;
			f.flags = flags;
			return iovcnt == 2 ? 0 : len-iov[0].iov_len;
		}
		rem -= cnt;
		if (cnt > iov[0].iov_len) {
			cnt -= iov[0].iov_len;
			iov++; iovcnt--;
		}
		iov[0].iov_base = cast(char *)iov[0].iov_base + cnt;
		iov[0].iov_len -= cnt;
	}
}
