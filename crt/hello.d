extern (C) int main() {
	print(cast(char*)"test");

	return 0;
}

int print(char* msg) {
	asm {
		mov     RAX, 0x2000004;
	    mov     RDI, 1;
	    mov     RSI, msg;
	    mov     RDX, 4;
	    syscall;

	}
	return 1;
}