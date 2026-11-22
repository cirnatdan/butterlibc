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

/// glibc dtv_t entry: each entry is a pair of pointers (val, to_free).
struct dtv_entry
{
    void* val;
    void* to_free;
}

/// Offset of the dtv field in glibc's tcbhead_t: x86_64 has tcb first
/// (dtv at offset 8); AArch64 has dtv first (offset 0).
version (X86_64)
    private enum size_t DTV_OFFSET = 8;
else version (AArch64)
    private enum size_t DTV_OFFSET = 0;
else
    private enum size_t DTV_OFFSET = 8;

/// Resolve a dynamic TLS slot via the thread's DTV.
void* __tls_get_addr(tls_index* ti) nothrow @nogc
{
    void* tp = thread_pointer();
    if (tp is null || ti is null)
        return null;
    // The TCB field at DTV_OFFSET already holds the DTV array pointer.
    auto dtv = cast(dtv_entry*)*cast(void**)(cast(size_t)tp + DTV_OFFSET);
    if (dtv is null || ti.ti_module == 0)
        return null;
    return cast(void*)(cast(size_t)dtv[ti.ti_module].val + ti.ti_offset);
}
