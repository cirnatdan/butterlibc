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
            "mov X8, 66; mov X0, %1; mov X1, %2; mov X2, %3; svc #0; mov %0, X0"
            : "=r"(result)
            : "r"(fd_ul), "r"(iov_ul), "r"(iovcnt_ul)
            : "x0", "x1", "x2", "x8", "memory";
        }
        return result;
    }
}
