/**
 * D header file for C99.
 *
 * $(C_HEADER_DESCRIPTION pubs.opengroup.org/onlinepubs/009695399/basedefs/_stdarg.h.html, _stdarg.h)
 *
 * Copyright: Copyright Digital Mars 2000 - 2009.
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Walter Bright, Hauke Duden
 * Standards: ISO/IEC 9899:1999 (E)
 * Source: $(DRUNTIMESRC core/stdc/_stdarg.d)
 */

@system:
@nogc:
nothrow:

version (X86)
{
    /*********************
     * The argument pointer type.
     */
    alias char* va_list;

    /**********
     * Initialize ap.
     * For 32 bit code, parmn should be the last named parameter.
     * For 64 bit code, parmn should be __va_argsave.
     */
    void va_start(T)(out va_list ap, ref T parmn)
    {
        ap = cast(va_list)( cast(void*) &parmn + ( ( T.sizeof + int.sizeof - 1 ) & ~( int.sizeof - 1 ) ) );
    }

    /************
     * Retrieve and return the next value that is type T.
     * Should use the other va_arg instead, as this won't work for 64 bit code.
     */
    T va_arg(T)(ref va_list ap)
    {
        T arg = *cast(T*) ap;
        ap = cast(va_list)( cast(void*) ap + ( ( T.sizeof + int.sizeof - 1 ) & ~( int.sizeof - 1 ) ) );
        return arg;
    }

    /************
     * Retrieve and return the next value that is type T.
     * This is the preferred version.
     */
    void va_arg(T)(ref va_list ap, ref T parmn)
    {
        parmn = *cast(T*)ap;
        ap = cast(va_list)(cast(void*)ap + ((T.sizeof + int.sizeof - 1) & ~(int.sizeof - 1)));
    }

    /***********************
     * End use of ap.
     */
    void va_end(va_list ap)
    {
    }

    ///
    void va_copy(out va_list dest, va_list src)
    {
        dest = src;
    }
}
else version (Windows) // Win64
{   /* Win64 is characterized by all arguments fitting into a register size.
     * Smaller ones are padded out to register size, and larger ones are passed by
     * reference.
     */

    /*********************
     * The argument pointer type.
     */
    alias char* va_list;

    /**********
     * Initialize ap.
     * parmn should be the last named parameter.
     */
    void va_start(T)(out va_list ap, ref T parmn); // Compiler intrinsic

    /************
     * Retrieve and return the next value that is type T.
     */
    T va_arg(T)(ref va_list ap)
    {
        static if (T.sizeof > size_t.sizeof)
            T arg = **cast(T**)ap;
        else
            T arg = *cast(T*)ap;
        ap = cast(va_list)(cast(void*)ap + ((size_t.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
        return arg;
    }

    /************
     * Retrieve and return the next value that is type T.
     * This is the preferred version.
     */
    void va_arg(T)(ref va_list ap, ref T parmn)
    {
        static if (T.sizeof > size_t.sizeof)
            parmn = **cast(T**)ap;
        else
            parmn = *cast(T*)ap;
        ap = cast(va_list)(cast(void*)ap + ((size_t.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
    }

    /***********************
     * End use of ap.
     */
    void va_end(va_list ap)
    {
    }

    ///
    void va_copy(out va_list dest, va_list src)
    {
        dest = src;
    }
}
else version (X86_64)
{
    // Determine if type is a vector type
    template isVectorType(T)
    {
        enum isVectorType = false;
    }

    template isVectorType(T : __vector(T[N]), size_t N)
    {
        enum isVectorType = true;
    }

    // Layout of this struct must match __gnuc_va_list for C ABI compatibility
    struct __va_list_tag
    {
        uint offset_regs = 6 * 8;            // no regs
        uint offset_fpregs = 6 * 8 + 8 * 16; // no fp regs
        void* stack_args;
        void* reg_args;
    }
    alias __va_list = __va_list_tag;

    align(16) struct __va_argsave_t
    {
        size_t[6] regs;   // RDI,RSI,RDX,RCX,R8,R9
        real[8] fpregs;   // XMM0..XMM7
        __va_list va;
    }

    /*
     * Making it an array of 1 causes va_list to be passed as a pointer in
     * function argument lists
     */
    alias va_list = __va_list*;

    ///
    void va_start(T)(out va_list ap, ref T parmn)
    {
        ap = cast(va_list)( cast(void*) &parmn + ( ( T.sizeof + int.sizeof - 1 ) & ~( int.sizeof - 1 ) ) );
    }

    ///
    T va_arg(T)(va_list ap)
    {   T a;
        va_arg(ap, a);
        return a;
    }

    ///
    void va_arg(T)(va_list apx, ref T parmn)
    {
        __va_list* ap = cast(__va_list*)apx;
        static if (is(T U == __argTypes))
        {
            static if (U.length == 0 || T.sizeof > 16 || (U[0].sizeof > 8 && !isVectorType!(U[0])))
            {   // Always passed in memory
                // The arg may have more strict alignment than the stack
                auto p = (cast(size_t)ap.stack_args + T.alignof - 1) & ~(T.alignof - 1);
                ap.stack_args = cast(void*)(p + ((T.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
                parmn = *cast(T*)p;
            }
            else static if (U.length == 1)
            {   // Arg is passed in one register
                alias U[0] T1;
                static if (is(T1 == double) || is(T1 == float) || isVectorType!(T1))
                {   // Passed in XMM register
                    if (ap.offset_fpregs < (6 * 8 + 16 * 8))
                    {
                        parmn = *cast(T*)(ap.reg_args + ap.offset_fpregs);
                        ap.offset_fpregs += 16;
                    }
                    else
                    {
                        parmn = *cast(T*)ap.stack_args;
                        ap.stack_args += (T1.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                    }
                }
                else
                {   // Passed in regular register
                    if (ap.offset_regs < 6 * 8 && T.sizeof <= 8)
                    {
                        parmn = *cast(T*)(ap.reg_args + ap.offset_regs);
                        ap.offset_regs += 8;
                    }
                    else
                    {
                        auto p = (cast(size_t)ap.stack_args + T.alignof - 1) & ~(T.alignof - 1);
                        ap.stack_args = cast(void*)(p + ((T.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1)));
                        parmn = *cast(T*)p;
                    }
                }
            }
            else static if (U.length == 2)
            {   // Arg is passed in two registers
                alias U[0] T1;
                alias U[1] T2;
                auto p = cast(void*)&parmn + 8;

                // Both must be in registers, or both on stack, hence 4 cases

                static if ((is(T1 == double) || is(T1 == float)) &&
                           (is(T2 == double) || is(T2 == float)))
                {
                    if (ap.offset_fpregs < (6 * 8 + 16 * 8) - 16)
                    {
                        *cast(T1*)&parmn = *cast(T1*)(ap.reg_args + ap.offset_fpregs);
                        *cast(T2*)p = *cast(T2*)(ap.reg_args + ap.offset_fpregs + 16);
                        ap.offset_fpregs += 32;
                    }
                    else
                    {
                        *cast(T1*)&parmn = *cast(T1*)ap.stack_args;
                        ap.stack_args += (T1.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                        *cast(T2*)p = *cast(T2*)ap.stack_args;
                        ap.stack_args += (T2.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                    }
                }
                else static if (is(T1 == double) || is(T1 == float))
                {
                    void* a = void;
                    if (ap.offset_fpregs < (6 * 8 + 16 * 8) &&
                        ap.offset_regs < 6 * 8 && T2.sizeof <= 8)
                    {
                        *cast(T1*)&parmn = *cast(T1*)(ap.reg_args + ap.offset_fpregs);
                        ap.offset_fpregs += 16;
                        a = ap.reg_args + ap.offset_regs;
                        ap.offset_regs += 8;
                    }
                    else
                    {
                        *cast(T1*)&parmn = *cast(T1*)ap.stack_args;
                        ap.stack_args += (T1.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                        a = ap.stack_args;
                        ap.stack_args += 8;
                    }
                    // Be careful not to go past the size of the actual argument
                    const sz2 = T.sizeof - 8;
                    p[0..sz2] = a[0..sz2];
                }
                else static if (is(T2 == double) || is(T2 == float))
                {
                    if (ap.offset_regs < 6 * 8 && T1.sizeof <= 8 &&
                        ap.offset_fpregs < (6 * 8 + 16 * 8))
                    {
                        *cast(T1*)&parmn = *cast(T1*)(ap.reg_args + ap.offset_regs);
                        ap.offset_regs += 8;
                        *cast(T2*)p = *cast(T2*)(ap.reg_args + ap.offset_fpregs);
                        ap.offset_fpregs += 16;
                    }
                    else
                    {
                        *cast(T1*)&parmn = *cast(T1*)ap.stack_args;
                        ap.stack_args += 8;
                        *cast(T2*)p = *cast(T2*)ap.stack_args;
                        ap.stack_args += (T2.sizeof + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
                    }
                }
                else // both in regular registers
                {
                    void* a = void;
                    if (ap.offset_regs < 5 * 8 && T1.sizeof <= 8 && T2.sizeof <= 8)
                    {
                        *cast(T1*)&parmn = *cast(T1*)(ap.reg_args + ap.offset_regs);
                        ap.offset_regs += 8;
                        a = ap.reg_args + ap.offset_regs;
                        ap.offset_regs += 8;
                    }
                    else
                    {
                        *cast(T1*)&parmn = *cast(T1*)ap.stack_args;
                        ap.stack_args += 8;
                        a = ap.stack_args;
                        ap.stack_args += 8;
                    }
                    // Be careful not to go past the size of the actual argument
                    const sz2 = T.sizeof - 8;
                    p[0..sz2] = a[0..sz2];
                }
            }
            else
            {
                static assert(false);
            }
        }
        else
        {
            static assert(false, "not a valid argument type for va_arg");
        }
    }

    ///
    void va_end(va_list ap)
    {
    }

    import core.stdc.stdlib : alloca;

    ///
    void va_copy(out va_list dest, va_list src, void* storage = alloca(__va_list_tag.sizeof))
    {
        // Instead of copying the pointers, and aliasing the source va_list,
        // the default argument alloca will allocate storage in the caller's
        // stack frame.  This is still not correct (it should be allocated in
        // the place where the va_list variable is declared) but most of the
        // time the caller's stack frame _is_ the place where the va_list is
        // allocated, so in most cases this will now work.
        dest = cast(va_list)storage;
        *dest = *src;
    }
}
else
{
    static assert(false, "Unsupported platform");
}