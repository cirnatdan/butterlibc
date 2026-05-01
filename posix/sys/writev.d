module posix.sys.writev;

version (Linux_Musl):
extern (C):
@system:
nothrow:
@nogc:

import posix.sys.types : ssize_t;
import posix.sys.uio : iovec;

// writev implementation for Linux_Musl
version (X86_64)
{
    ssize_t writev(int fd, const scope iovec* iov, int iovcnt)
    {
        ssize_t result;
        ulong fd_ul = cast(ulong)fd;
        ulong iov_ul = cast(ulong)iov;
        ulong iovcnt_ul = cast(ulong)iovcnt;
        asm @nogc nothrow
        {
            mov RAX, 20;         // writev syscall number
            mov RDI, fd_ul;
            mov RSI, iov_ul;
            mov RDX, iovcnt_ul;
            syscall;
            mov result, RAX;
        }
        return result;
    }
}
else version (AArch64)
{
    ssize_t writev(int fd, const scope iovec* iov, int iovcnt)
    {
        ssize_t result;
        ulong fd_ul = cast(ulong)fd;
        ulong iov_ul = cast(ulong)iov;
        ulong iovcnt_ul = cast(ulong)iovcnt;
        asm @nogc nothrow
        {
            mov X8, 66;          // writev syscall number for AArch64
            mov X0, fd_ul;
            mov X1, iov_ul;
            mov X2, iovcnt_ul;
            svc #0;
            mov result, X0;
        }
        return result;
    }
}
