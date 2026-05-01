DMD ?= ldmd2
VERSION ?= Linux_Musl
OS = linux
ARCH ?= X86_64

# Cross-compiler tools (set via command line for AArch64)
AS ?= as
CC ?= gcc
LD ?= ld

# Compiler-specific flags
.if ${DMD} == "dmd"
# DMD compiler - avoid standard library imports with -betterC and disable bounds checking
DMD_FLAGS ?= -m64 -noboundscheck
.else
# LDC compiler (default)
DMD_FLAGS ?= -m64
.endif

default: crt0.o
	$(DMD) -fPIC -betterC -c -defaultlib= -conf= -version=$(VERSION) *.d -op -debug $(DMD_FLAGS)
	$(DMD) -fPIC -betterC -c -version=$(VERSION) exit/*.d -unittest -op -debug $(DMD_FLAGS)
	$(DMD) -fPIC -betterC -c -defaultlib= -conf= -version=$(VERSION) posix/*.d -unittest -op -debug $(DMD_FLAGS)
	$(DMD) -fPIC -betterC -c -defaultlib= -conf= -version=$(VERSION) posix/sys/*.d -unittest -op -debug $(DMD_FLAGS)
	$(DMD) -fPIC -betterC -c -version=$(VERSION) stdlib/abs.d -unittest -op -debug $(DMD_FLAGS)
	$(DMD) -fPIC -betterC -c -version=$(VERSION) prng/rand.d -unittest -op -debug $(DMD_FLAGS)
	$(DMD) -fPIC -betterC -c -defaultlib= -conf= -version=$(VERSION) stdio/*.d -op -debug $(DMD_FLAGS)
	$(DMD) -fPIC -betterC -c -defaultlib= -conf= -version=$(VERSION) sys/linux/*.d -op -debug $(DMD_FLAGS)
	$(DMD) -fPIC -betterC -c -version=$(VERSION) string/*.d -op -debug $(DMD_FLAGS)

crt0.o: crt/$(OS)/$(ARCH)/crt0.s
	$(AS) -o crt0.o crt/$(OS)/$(ARCH)/crt0.s

libbutterc.so: default crt0.o
	$(LD) -o libbutterc.so */*/*.o */*.o *.o -shared

test: default crt0.o
	$(DMD) -betterC -c -version=$(VERSION) tests/tests.d -op -debug $(DMD_FLAGS)
	$(LD) -o tests.exe -static crt0.o stdio/printf.o string.o prng/rand.o stdarg.o exit/assert.o string/memcpy.o object.o posix/sys/writev.o tests/*.o #-macosx_version_min 10.7.0
	./tests.exe

all: libbutterc.so

clean:
	rm tests.exe || true
	rm *.o */*.o || true
	rm *.dylib || true
