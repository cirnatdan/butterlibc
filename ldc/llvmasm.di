// copied from LDC source code to support inline ASM
module ldc.llvmasm;

struct __asmtuple_t(T...)
{
    T v;
}

pragma(LDC_inline_asm)
{
    void __asm()(const(char)[] asmcode, const(char)[] constraints, ...) pure nothrow @nogc;
    T __asm(T)(const(char)[] asmcode, const(char)[] constraints, ...) pure nothrow @nogc;

    void __asm_trusted()(const(char)[] asmcode, const(char)[] constraints, ...) @trusted pure nothrow @nogc;
    T __asm_trusted(T)(const(char)[] asmcode, const(char)[] constraints, ...) @trusted pure nothrow @nogc;

    template __asmtuple(T...)
    {
        __asmtuple_t!(T) __asmtuple(const(char)[] asmcode, const(char)[] constraints, ...);
    }
}
