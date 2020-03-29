extern (C) void __assert_rtn(const char* x, const char* y, const char* z, const char* w)
{
    version(AArch64) {
        //TODO ARM assert
    } else {
	    asm {
		    mov     RAX, 0x2000004;
	        mov     RDI, 1;
	        mov     RSI, x;
	        mov     RDX, 10;
	        syscall;
	    }
    }
}

extern (C) void __assert(const char* file, const char* x, uint line)
{
    assert(false, "not implemented");
}
