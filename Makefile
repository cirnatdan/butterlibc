default:
	nasm -f macho64 crt/crt0.s
	dmd -betterC -c exit/assert.d -unittest -op -debug -m64
	dmd -betterC -c stdlib/abs.d -unittest -op -debug -m64
	dmd -betterC -c prng/rand.d -unittest -op -debug -m64
	dmd -betterC -c tests/tests.d -op -debug -m64
	dmd -betterC -c tests/debug_print.d -op -debug -m64
	dmd -betterC -c *.d -op -debug -m64
	dmd -betterC -c stdio/*.d -op -debug -m64
	ld -o tests.exe -macosx_version_min 10.7.0 -static tests/*.o exit/assert.o stdlib/abs.o prng/rand.o crt/crt0.o stdio/*.o *.o
	./tests.exe

clean:
	rm tests.exe
	rm *.o */*.o