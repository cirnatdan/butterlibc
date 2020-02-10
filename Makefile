DMD ?= ldmd2
VERSION ?= Linux_Musl

default:
	$(DMD) -fPIC -betterC -c -version=$(VERSION) *.d -op -debug -m64
	$(DMD) -fPIC -betterC -c -version=$(VERSION) exit/*.d -unittest -op -debug -m64
	$(DMD) -fPIC -betterC -c -version=$(VERSION) posix/*.d -unittest -op -debug -m64
	$(DMD) -fPIC -betterC -c -version=$(VERSION) stdlib/abs.d -unittest -op -debug -m64
	$(DMD) -fPIC -betterC -c -version=$(VERSION) prng/rand.d -unittest -op -debug -m64
	$(DMD) -fPIC -betterC -c -version=$(VERSION) stdio/*.d -op -debug -m64
	$(DMD) -fPIC -betterC -c -version=$(VERSION) string/*.d -op -debug -m64

lib:
	# build shared lib
	#dmd -oflibdlibc.dylib -betterC */*.o *.o -shared
	nasm -f macho64 linker/dyld_stub_binder.s
	ld -o libdlibc.dylib */*.o *.o -macosx_version_min 10.7.0 -dylib

test:
	#nasm -f macho64 crt/crt0.s
	# build and run tests
	$(DMD) -betterC -c tests/tests.d -op -debug -m64
	$(DMD) -betterC -c tests/debug_print.d -op -debug -m64
	ld -o tests.exe -macosx_version_min 10.7.0 -static */*.o *.o
	./tests.exe

clean:
	rm tests.exe || true
	rm *.o */*.o || true
	rm *.dylib || true
