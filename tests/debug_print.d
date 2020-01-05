@nogc
extern(C) void debug_print(char* msg, short* length) {
	asm @nogc{
		mov     RAX, 0x2000004;
	    mov     RDI, 1;
	    mov     RSI, msg;
	    mov     RDX, length;
	    syscall;

	}
}