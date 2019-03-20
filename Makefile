default:
	nasm -f macho64 crt/crt0.s
	dmd -betterC -c crt/hello.d -op -debug -m64
	ld -o hello -macosx_version_min 10.7.0 -static crt/hello.o crt/crt0.o
	./hello