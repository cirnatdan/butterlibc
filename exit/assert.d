extern (C) void __assert_rtn(const char* x, const char* y, const char* z, const char* w)
{
    version(AArch64) {
        asm {
            mov X8, 64;         // write syscall number
            mov X0, 2;          // stderr fd
            mov X1, x;          // message pointer
            mov X2, 10;         // message length
            svc #0;
            mov X8, 93;         // exit syscall number
            mov X0, 1;          // exit status 1 (failure)
            svc #0;
        }
    } else {
	    asm {
		    mov     RAX, 0x2000004;
	        mov     RDI, 1;
	        mov     RSI, x;
	        mov     RDX, 10;
	        syscall;
	        mov     RAX, 60;       // exit syscall
	        mov     RDI, 1;        // exit status 1 (failure)
	        syscall;
	    }
    }
}

extern (C) void __assert(const char* file, const char* x, uint line)
{
    // Simple assert implementation for BetterC mode
    version(AArch64) {
        asm {
            // Compute file string length
            mov X1, file;       // file string pointer
            mov X2, 0;          // length counter
        length_loop_arm:
            ldrb W3, [X1, X2];  // load byte
            cbz W3, length_done_arm; // check for NUL
            add X2, X2, 1;      // increment length
            b length_loop_arm;
        length_done_arm:
            // Write file name
            mov X8, 64;         // write syscall number
            mov X0, 2;          // stderr fd
            mov X1, file;       // file string pointer
            svc #0;
            
            // Write ": " separator
            mov X8, 64;
            mov X0, 2;
            adrp X1, colon_space;
            add X1, X1, :lo12:colon_space;
            mov X2, 2;
            svc #0;
            
            // Write expression string
            mov X1, x;          // expression pointer
            mov X2, 0;          // reset length counter
        expr_loop_arm:
            ldrb W3, [X1, X2];  // load byte
            cbz W3, expr_done_arm; // check for NUL
            add X2, X2, 1;      // increment length
            b expr_loop_arm;
        expr_done_arm:
            mov X8, 64;
            mov X0, 2;
            mov X1, x;          // expression pointer
            svc #0;
            
            // Write " at line " prefix
            mov X8, 64;
            mov X0, 2;
            adrp X1, at_line_space;
            add X1, X1, :lo12:at_line_space;
            mov X2, 9;
            svc #0;
            
            // Convert line number to string and write
            mov X3, line;       // line number
            mov X4, 10;         // base 10
            adrp X5, line_buffer;
            add X5, X5, :lo12:line_buffer;
            add X5, X5, 10;     // end of buffer
            mov W6, 10;         // newline character
            strb W6, [X5];
            sub X5, X5, 1;
        itoa_loop_arm:
            udiv X6, X3, X4;    // X6 = X3 / 10
            msub X7, X6, X4, X3; // X7 = X3 - (X6 * 10) = remainder
            add X7, X7, 48;     // convert to ASCII
            strb W7, [X5];
            sub X5, X5, 1;
            mov X3, X6;
            cbnz X3, itoa_loop_arm;
            add X5, X5, 1;      // point to start of number
            
            // Calculate line number string length
            adrp X6, line_buffer;
            add X6, X6, :lo12:line_buffer;
            add X6, X6, 11;     // end of buffer + newline
            sub X2, X6, X5;
            
            mov X8, 64;
            mov X0, 2;
            mov X1, X5;         // line number string pointer
            svc #0;
            
            // Terminate process
            mov X8, 93;         // exit syscall number
            mov X0, 1;          // exit status 1 (failure)
            svc #0;
        }
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
        
        // Terminate process
        mov     RAX, 60;        // exit syscall
        mov     RDI, 1;         // exit status 1 (failure)
        syscall;
	    }
    }
}

// Data strings for assert output
extern (C) __gshared const char[2] colon_space = ": ";
extern (C) __gshared const char[9] at_line_space = " at line ";
extern (C) __gshared char[11] line_buffer; // buffer for line number conversion
