# Building pkgsrc Packages Against butterlibc

This document describes how to configure and build pkgsrc packages to use butterlibc instead of the system C library.

## Introduction

butterlibc is a small, portable C library implementation. This document explains how to configure pkgsrc to build packages against butterlibc, allowing you to use butterlibc as the C library for selected packages.

## Prerequisites

1. butterlibc built (using `bmake all` or `bmake libbutterc.so` in the butterlibc directory, so that both `libbutterc.so` and `crt0.o` exist)
2. pkgsrc bootstrapped on your system (typically at `/opt/pkg/src`)
3. Musl libc headers installed (for Linux builds, typically at `/usr/include/x86_64-linux-musl`)

## Configuration

### mk.conf configuration

Add the following configuration to your `/opt/pkg/etc/mk.conf`:

```makefile
# butterlibc configuration - adjust paths as needed
BUTTERLIBC_DIR?=    /home/dan/Projects/butterlibc
MUSL_INCLUDE_DIR?=  /usr/include/x86_64-linux-musl

# Enable butterlibc for specific builds
.if ${USE_BUTTERLIBC:Uno} == yes
CC=        /home/dan/Projects/butterlibc/buttercc
CFLAGS+=  -I${MUSL_INCLUDE_DIR} -fno-stack-protector -ffreestanding -fno-builtin -D_FORTIFY_SOURCE=0
LDFLAGS+= -L${BUTTERLIBC_DIR} -lbutterc -Wl,-R${BUTTERLIBC_DIR}
USE_CWRAPPERS=    no
_GCC_CWRAPPERS=
.endif
```

**Important notes:**
- The `buttercc` wrapper script must be available at the specified path
- `BUTTERLIBC_DIR` should point to your butterlibc build directory or installation prefix
- `MUSL_INCLUDE_DIR` should point to the musl libc headers directory
- The `:Uno` modifier provides a default value for `USE_BUTTERLIBC` to avoid syntax errors

### buttercc wrapper script

Create a `buttercc` script that wraps the system compiler. Example:

```sh
#!/bin/sh
# buttercc - Compiler wrapper for butterlibc
# Resolve the butterlibc directory from this script's own location, and put
# -lbutterc after the caller's object files so --as-needed linkers keep it.
BUTTERLIBC_DIR=${BUTTERLIBC_DIR:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}
MUSL_INCLUDE_DIR=${MUSL_INCLUDE_DIR:-/usr/include/x86_64-linux-musl}
exec cc -nostdlib "${BUTTERLIBC_DIR}/crt0.o" \
    -I"${MUSL_INCLUDE_DIR}" \
    "$@" -fno-stack-protector -ffreestanding -fno-builtin \
    -L"${BUTTERLIBC_DIR}" -lbutterc
```

Notes:
- The hardening flags come *after* the caller's arguments so they win over default flags like `-fstack-protector-strong`.
- `-lbutterc` comes after the caller's object files so `--as-needed` linkers retain the library.

Install it to a directory in your PATH (e.g., `${BUTTERLIBC_DIR}/buttercc`) and make it executable.

This script:
1. Uses `-nostdlib` to prevent linking with the system libc
2. Links in butterlibc's `crt0.o` as the program entry point
3. Links against `libbutterc.so`
4. Passes all other arguments through to the system compiler

## Building Packages

To build a package with butterlibc, set the `USE_BUTTERLIBC` environment variable:

```bash
cd /opt/pkg/src/misc/ascii
bmake clean
USE_BUTTERLIBC=yes bmake
```

### Example: Building misc/ascii

The `misc/ascii` package is a good test case as it only requires basic stdio functions:

```bash
cd /opt/pkg/src/misc/ascii
bmake clean
USE_BUTTERLIBC=yes bmake
```

If the pkgsrc build has issues, you can compile manually:

```bash
# Generate header files
cd /opt/pkg/src/misc/ascii/work/ascii-3.32
sed <splashscreen >splashscreen.h -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/.*/"&" "\\n"/'
sed <nametable >nametable.h -e '/^#/d' -e 's/^[A-Za-z ]*: */    /' -e 's/%%/    }, {/'

# Compile
/home/dan/Projects/butterlibc/buttercc \
    -I/usr/include/x86_64-linux-musl \
    -DREVISION='"3.32"' ascii.c -o ascii_final
```

## Verification

To verify that a package is linked against butterlibc:

```bash
ldd /path/to/binary | grep butterc
```

You should see `libbutterc.so` in the output, not `libc.so.6`.

To test the binary:

```bash
LD_LIBRARY_PATH=/home/dan/Projects/butterlibc:$LD_LIBRARY_PATH \
    /path/to/ascii 65
```

This should display ASCII information for all characters matching '65' (which is 'A' in ASCII).

## Files Modified/Added for pkgsrc Support

The following files were added or modified to support building pkgsrc packages with butterlibc:

- `crt/linux/X86_64/crt0.s` - Entry point for Linux x86_64 that properly sets up argc/argv
- `stdio/package.d` - Added fprintf, vfprintf, and fputs implementations for Linux_Musl
- `posix/sys/ioctl.d` - Added ioctl implementation for Linux_Musl
- `tls.d` - TLS stub implementation (provides __tls_get_addr)
- `buttercc` - Compiler wrapper script
- `/opt/pkg/etc/mk.conf` - pkgsrc configuration

## Current Status

### Working
- Basic stdio output (printf, fprintf, vfprintf, fputs)
- Program entry/exit (_start, exit, _exit)
- Compilation and linking with `-nostdlib`

### Known Limitations
- Some stdio functions (e.g., fread, fwrite, fopen) are not yet implemented for Linux_Musl
- FILE stream operations may not work correctly for all use cases
- Only x86_64 Linux is currently tested and supported
- Packages that require advanced libc features will not work

## Troubleshooting

### Compilation fails with "undefined reference"

This error typically means that butterlibc is missing an implementation of a function that the package requires. Check which function is undefined and verify that butterlibc implements it for the Linux_Musl platform.

### Build succeeds but binary is still linked against system libc

Verify the build command includes:
1. `-nostdlib` flag
2. butterlibc's `crt0.o` file
3. `-lbutterc` flag to link against libbutterc.so

### Segmentation fault at runtime

Common causes:
1. crt0.o not properly setting up the stack or passing arguments to main
2. Uninitialized stdin/stdout/stderr FILE structures
3. Missing implementation of a required function

### pkgsrc build fails with "Error 1" even though compilation succeeds

This may be due to:
1. The package's Makefile using GNU make features that bmake doesn't support
2. Other build steps failing (like documentation generation)

As a workaround, compile the source directly with buttercc.

## Tips

1. **Start simple**: Begin with packages that have minimal dependencies like `misc/ascii`
2. **Check function usage**: Use `grep` to find which C library functions a package uses
3. **Test manually**: If pkgsrc build fails, try compiling the source directly with buttercc
4. **Verify linking**: Always check with `ldd` that the final binary is linked against butterlibc
5. **Check butterlibc implementations**: Refer to the butterlibc source to see which functions are implemented for your platform
