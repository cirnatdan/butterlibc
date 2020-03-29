DMD ?= ldmd2
VERSION ?= Linux_Musl
OS = linux
ARCH ?= aarch64

default: crt0.o
	$(DMD) -fPIC -betterC -c -defaultlib= -conf= -version=$(VERSION) *.d -op -debug -m64
	$(DMD) -fPIC -betterC -c -version=$(VERSION) exit/*.d -unittest -op -debug -m64
	$(DMD) -fPIC -betterC -c -version=$(VERSION) posix/*.d -unittest -op -debug -m64
	$(DMD) -fPIC -betterC -c -version=$(VERSION) stdlib/abs.d -unittest -op -debug -m64
	$(DMD) -fPIC -betterC -c -version=$(VERSION) prng/rand.d -unittest -op -debug -m64
	$(DMD) -fPIC -betterC -c -defaultlib= -conf= -version=$(VERSION) stdio/*.d -op -debug -m64
	$(DMD) -fPIC -betterC -c -version=$(VERSION) string/*.d -op -debug -m64

crt0.o: crt/$(OS)/$(ARCH)/crt0.s
	as -o crt0.o crt/$(OS)/$(ARCH)/crt0.s

lib: default crt0.o
	# build shared lib
	#dmd -oflibdlibc.dylib -betterC */*.o *.o -shared
	nasm -f macho64 linker/dyld_stub_binder.s
	ld -o libdlibc.dylib */*.o *.o -macosx_version_min 10.7.0 -dylib

test: crt0.o
	#nasm -f macho64 crt/crt0.s
	# build and run tests
	$(DMD) -betterC -c -version=$(VERSION) tests/tests.d -op -debug -m64
	#$(DMD) -betterC -c -version=$(VERSION) tests/debug_print.d -op -debug -m64
	ld -o tests.exe -static crt0.o stdio/printf.o string.o prng/rand.o stdarg.o exit/assert.o string/memcpy.o object.o tests/*.o #-macosx_version_min 10.7.0
	./tests.exe

clean:
	rm tests.exe || true
	rm *.o */*.o || true
	rm *.dylib || true
