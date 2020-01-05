extern (C) start() {
	asm @naked{
		mov RBP, RSP
		mov rdi, [rbp]
		lea rsi, [rbp+8]
		call _main

		mov     rax, 0x2000001 ; exit
		mov     rdi, 0
		syscall
	}
}