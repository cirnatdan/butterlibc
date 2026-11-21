/*
 * TLS support for butterlibc
 *
 * Provides __tls_get_addr (glibc ABI) so that general-dynamic TLS accesses
 * from libbutterc.so resolve correctly. The dynamic linker's DTV is used;
 * only statically loaded modules are supported (no dlopen yet).
 */

module tls;

version (Posix):

extern (C):

/// glibc ABI tls_index passed to __tls_get_addr
struct tls_index
{
    size_t ti_module;
    size_t ti_offset;
}

private void* thread_pointer() nothrow @nogc
{
    version (X86_64)
    {
        void* tp;
        asm nothrow @nogc
        {
            mov RAX, FS:0;
            mov tp, RAX;
        }
        return tp;
    }
    else version (AArch64)
    {
        import ldc.llvmasm;
        return __asm!(void*)("mrs $0, tpidr_el0", "=r");
    }
    else
    {
        return null;
    }
}

/// Resolve a dynamic TLS slot via the thread's DTV (glibc tcbhead_t layout:
/// tcb at offset 0, dtv at offset 8).
void* __tls_get_addr(tls_index* ti) nothrow @nogc
{
    void* tp = thread_pointer();
    if (tp is null || ti is null)
        return null;
    void** dtv = *cast(void***)(cast(size_t)tp + 8);
    if (dtv is null || ti.ti_module == 0)
        return null;
    return cast(void*)(cast(size_t)dtv[ti.ti_module] + ti.ti_offset);
}
