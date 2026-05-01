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
		    // Compute file string length
		    mov     RSI, file;      // file string pointer
		    xor     RCX, RCX;       // length counter
		length_loop:
		    cmp     [RSI + RCX], 0; // check for NUL
		    je      length_done;
		    inc     RCX;
		    jmp     length_loop;
		length_done:
		    // Write file name
		    mov     RAX, 1;         // write syscall number
	        mov     RDI, 2;         // stderr fd
	        mov     RSI, file;      // file string pointer
	        mov     RDX, RCX;       // actual file name length
	        syscall;
	        
	        // Write ": " separator
	        mov     RAX, 1;
	        mov     RDI, 2;
	        mov     RSI, colon_space;
	        mov     RDX, 2;
	        syscall;
	        
	        // Write expression string
	        mov     RSI, x;         // expression pointer
	        xor     RCX, RCX;       // reset length counter
		expr_loop:
		    cmp     [RSI + RCX], 0; // check for NUL
		    je      expr_done;
		    inc     RCX;
		    jmp     expr_loop;
		expr_done:
		    mov     RAX, 1;
	        mov     RDI, 2;
	        mov     RDX, RCX;       // expression length
	        syscall;
	        
	        // Write " at line " prefix
	        mov     RAX, 1;
	        mov     RDI, 2;
	        mov     RSI, at_line_space;
	        mov     RDX, 9;
	        syscall;
	        
	        // Convert line number to string and write
	        mov     RAX, line;      // line number
	        mov     RDI, 10;        // base 10
	        mov     RSI, line_buffer; // buffer start
	        add     RSI, 10;        // end of buffer
	        mov     [RSI], 10;      // newline
	        dec     RSI;
		itoa_loop:
		    xor     RDX, RDX;
		    div     RDI;            // RAX = RAX / 10, RDX = remainder
		    add     RDX, 48;        // convert to ASCII ('0' = 48)
		    mov     [RSI], DL;
		    dec     RSI;
		    test    RAX, RAX;
		    jnz     itoa_loop;
	        inc     RSI;             // point to start of number
	        
	        // Calculate line number string length
	        mov     RCX, line_buffer; // buffer start
	        add     RCX, 11;        // end of buffer + newline
	        sub     RCX, RSI;
	        
	        mov     RAX, 1;
	        mov     RDI, 2;
	        mov     RDX, RCX;       // line number string length
	        syscall;
	    }
    }
}

// Data strings for assert output
extern (C) __gshared const char[2] colon_space = ": ";
extern (C) __gshared const char[9] at_line_space = " at line ";
extern (C) __gshared char[11] line_buffer; // buffer for line number conversion
