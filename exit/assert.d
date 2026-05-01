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
    // Simple assert implementation for BetterC mode
    version(AArch64) {
        //TODO ARM assert
    } else {
	    asm {
		    mov     RAX, 1;         // write syscall number
	        mov     RDI, 2;         // stderr fd
	        mov     RSI, file;
	        mov     RDX, 10;       // approximate length
	        syscall;
	    }
    }
}
