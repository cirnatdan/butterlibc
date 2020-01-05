extern (C) void __assert_rtn(const char* x, const char* y)
{
	asm {
		mov     RAX, 0x2000004;
	    mov     RDI, 1;
	    mov     RSI, x;
	    mov     RDX, 10;
	    syscall;

	}
}