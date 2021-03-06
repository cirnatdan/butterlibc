/**
 * D header file for C99 <stdio.h>
 *
 * $(C_HEADER_DESCRIPTION pubs.opengroup.org/onlinepubs/009695399/basedefs/_stdio.h.html, _stdio.h)
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Authors:   Sean Kelly,
 *            Alex Rønne Petersen
 * Source:    https://github.com/dlang/druntime/blob/master/src/core/stdc/stdio.d
 * Standards: ISO/IEC 9899:1999 (E)
 */
module stdio;

version (OSX)
    version = Darwin;
else version (iOS)
    version = Darwin;
else version (TVOS)
    version = Darwin;
else version (WatchOS)
    version = Darwin;

private
{
    import config;
    import stdarg; // for va_list
    import stdint : intptr_t;
    import wchar_;
    import errno;
    import posix.locale;
    import posix.sys.types;

  version (FreeBSD)
  {
    import core.sys.posix.sys.types;
  }
  else version (OpenBSD)
  {
    import core.sys.posix.sys.types;
  }
  version (NetBSD)
  {
    import core.sys.posix.sys.types;
  }
  version (DragonFlyBSD)
  {
    import core.sys.posix.sys.types;
  }
}

extern (C):
@system:
nothrow:
@nogc:

version (CRuntime_DigitalMars)
{
    enum
    {
        ///
        BUFSIZ       = 0x4000,
        ///
        EOF          = -1,
        ///
        FOPEN_MAX    = 20,
        ///
        FILENAME_MAX = 256, // 255 plus NULL
        ///
        TMP_MAX      = 32767,
        ///
        SYS_OPEN     = 20,      // non-standard
    }

    ///
    enum int     _NFILE     = 60;       // non-standard
    ///
    enum string  _P_tmpdir  = "\\"; // non-standard
    ///
    enum wstring _wP_tmpdir = "\\"; // non-standard
    ///
    enum int     L_tmpnam   = _P_tmpdir.length + 12;
}
else version (CRuntime_Microsoft)
{
    enum
    {
        ///
        BUFSIZ       = 512,
        ///
        EOF          = -1,
        ///
        FOPEN_MAX    = 20,
        ///
        FILENAME_MAX = 260,
        /// Actually int.max since Visual Studio 2015.
        TMP_MAX      = 32767,
        ///
        _SYS_OPEN    = 20,      // non-standard
    }

    ///
    enum int     _NFILE     = 512;       // non-standard
    /// Removed since Visual Studio 2015.
    enum string  _P_tmpdir  = "\\"; // non-standard
    /// Removed since Visual Studio 2015.
    enum wstring _wP_tmpdir = "\\"; // non-standard
    /// Actually 260 since Visual Studio 2015.
    enum int     L_tmpnam   = _P_tmpdir.length + 12;
}
else version (Linux_Glibc)
{
    enum
    {
        ///
        BUFSIZ       = 8192,
        ///
        EOF          = -1,
        ///
        FOPEN_MAX    = 16,
        ///
        FILENAME_MAX = 4095,
        ///
        TMP_MAX      = 238328,
        ///
        L_tmpnam     = 20
    }
}
else version (Linux_Musl)
{
    enum
    {
        ///
        BUFSIZ       = 1024,
        ///
        EOF          = -1,
        ///
        FOPEN_MAX    = 1000,
        ///
        FILENAME_MAX = 4096,
        ///
        TMP_MAX      = 10000,
        ///
        L_tmpnam     = 20
    }
}
else version (Darwin)
{
    enum
    {
        ///
        BUFSIZ       = 1024,
        ///
        EOF          = -1,
        ///
        FOPEN_MAX    = 20,
        ///
        FILENAME_MAX = 1024,
        ///
        TMP_MAX      = 308915776,
        ///
        L_tmpnam     = 1024,
    }

    private
    {
        struct __sbuf
        {
            ubyte*  _base;
            int     _size;
        }

        struct __sFILEX
        {

        }
    }
}
else version (FreeBSD)
{
    enum
    {
        ///
        BUFSIZ       = 1024,
        ///
        EOF          = -1,
        ///
        FOPEN_MAX    = 20,
        ///
        FILENAME_MAX = 1024,
        ///
        TMP_MAX      = 308915776,
        ///
        L_tmpnam     = 1024
    }

    struct __sbuf
    {
        ubyte *_base;
        int _size;
    }
}
else version (NetBSD)
{
    enum
    {
        ///
        BUFSIZ       = 1024,
        ///
        EOF          = -1,
        ///
        FOPEN_MAX    = 20,
        ///
        FILENAME_MAX = 1024,
        ///
        TMP_MAX      = 308915776,
        ///
        L_tmpnam     = 1024
    }

    struct __sbuf
    {
        ubyte *_base;
        int _size;
    }
}
else version (OpenBSD)
{
    enum
    {
        ///
        BUFSIZ       = 1024,
        ///
        EOF          = -1,
        ///
        FOPEN_MAX    = 20,
        ///
        FILENAME_MAX = 1024,
        ///
        TMP_MAX      = 0x7fffffff,
        ///
        L_tmpnam     = 1024
    }

    struct __sbuf
    {
        ubyte *_base;
        int _size;
    }
}
else version (DragonFlyBSD)
{
    enum
    {
        BUFSIZ       = 1024,
        EOF          = -1,
        FOPEN_MAX    = 20,
        FILENAME_MAX = 1024,
        TMP_MAX      = 308915776,
        L_tmpnam     = 1024
    }

    struct __sbuf {                     // <sys/sbuf.h>
        byte*            s_buf;         // storage buffer
        int function(void *, const char *, int) sbuf_drain_func;
        void*            s_drain_arg;   // user-supplied drain argument
        int              s_error;       // current error code
        ssize_t          s_size;        // size of storage buffer
        ssize_t          s_len;         // current length of string
        int              s_flags;       // flags
        ssize_t          s_sect_len;    // current length of section
    };

    enum {
        SBUF_FIXEDLEN   = 0x00000000,   // fixed length buffer (default)
        SBUF_AUTOEXTEND = 0x00000001,   // automatically extend buffer
        SBUF_USRFLAGMSK = 0x0000ffff,   // mask of flags the user may specify
        SBUF_DYNAMIC    = 0x00010000,   // s_buf must be freed
        SBUF_FINISHED   = 0x00020000,   // set by sbuf_finish()
        SBUF_DYNSTRUCT  = 0x00080000,   // sbuf must be freed
        SBUF_INSECTION  = 0x00100000,   // set by sbuf_start_section()
    }
}
else version (Solaris)
{
    enum
    {
        ///
        BUFSIZ = 1024,
        ///
        EOF = -1,
        ///
        FOPEN_MAX = _NFILE,
        ///
        FILENAME_MAX = 1024,
        ///
        TMP_MAX = 17576,
        ///
        L_tmpnam = 25,
    }

    version (X86)
        ///
        enum int _NFILE = 60;
    else
        ///
        enum int _NFILE = 20;
}
else version (CRuntime_Bionic)
{
    enum
    {
        ///
        BUFSIZ       = 1024,
        ///
        EOF          = -1,
        ///
        FOPEN_MAX    = 20,
        ///
        FILENAME_MAX = 1024,
        ///
        TMP_MAX      = 308915776,
        ///
        L_tmpnam     = 1024
    }

    struct __sbuf
    {
        ubyte* _base;
        int _size;
    }
}
else version (CRuntime_UClibc)
{
    enum
    {
        ///
        BUFSIZ       = 4096,
        ///
        EOF          = -1,
        ///
        FOPEN_MAX    = 16,
        ///LOCALE_NAME_MAX 23
        FILENAME_MAX = 4095,
        ///
        TMP_MAX      = 238328,
        ///
        L_tmpnam     = 20
    }
}
else
{
    static assert( false, "Unsupported platform" );
}

enum
{
    /// Offset is relative to the beginning
    SEEK_SET,
    /// Offset is relative to the current position
    SEEK_CUR,
    /// Offset is relative to the end
    SEEK_END
}

version (CRuntime_DigitalMars)
{
    ///
    alias c_long fpos_t;

    ///
    struct _iobuf
    {
        char* _ptr;
        int   _cnt;
        char* _base;
        int   _flag;
        int   _file;
        int   _charbuf;
        int   _bufsiz;
        char* __tmpnum;
    }

    ///
    alias shared(_iobuf) FILE;

}
else version (CRuntime_Microsoft)
{
    ///
    alias long fpos_t;

    ///
    struct _iobuf
    {
        void* undefined;
    }

    ///
    alias shared(_iobuf) FILE;
}
else version(Linux_Musl)
{
    enum UNGET = 8;

    enum {
        F_PERM = 1,
        F_NORD = 4,
        F_NOWR = 8,
        F_ERR  = 32,
        F_EOF  = 16,
        F_SVB  = 64,
    }
    union fpos_t
    {
        char[16] __opaque = 0;
        double __align;
    }
    extern(C) struct _IO_FILE {
	    uint flags;
	    ubyte* rpos, rend;
	    int function(FILE*) close;
	    ubyte* wend, wpos;
	    ubyte *mustbezero_1;
	    ubyte *wbase;
	    @nogc nothrow size_t function(FILE *, ubyte *, size_t) read;
	    @nogc nothrow size_t function(FILE *, const ubyte *, size_t) write;
	    off_t function(FILE *, off_t, int) seek;
	    ubyte *buf;
	    size_t buf_size;
	    FILE* prev, next;
	    int fd;
	    int pipe_pid;
	    long lockcount;
	    int mode;
	    /*volatile*/ int lock;
	    int lbf;
	    void *cookie;
	    off_t off;
	    char *getln_buf;
	    void *mustbezero_2;
	    ubyte *shend;
	    off_t shlim, shcnt;
	    FILE* prev_locked, next_locked;
	    __locale_struct *locale;
    };

    ///
    alias _IO_FILE _iobuf; // needed for phobos
    ///
    alias shared(_IO_FILE) FILE;
}
else version (Darwin)
{
    ///
    alias long fpos_t;

    ///
    struct __sFILE
    {
        ubyte*    _p;
        int       _r;
        int       _w;
        short     _flags;
        short     _file;
        __sbuf    _bf;
        int       _lbfsize;

        void*     _cookie;
        int     function(void*)                    _close;
        int     function(void*, char*, int)        _read;
        fpos_t  function(void*, fpos_t, int)       _seek;
        int     function(void*, char *, int)       _write;

        __sbuf    _ub;
        __sFILEX* _extra;
        int       _ur;

        ubyte[3]  _ubuf;
        ubyte[1]  _nbuf;

        __sbuf    _lb;

        int       _blksize;
        fpos_t    _offset;
    }

    ///
    alias __sFILE _iobuf;
    ///
    alias __sFILE FILE;
}
else version (FreeBSD)
{
    // Need to import wchar_ now since __mbstate_t now resides there
    import core.stdc.wchar_ : mbstate_t;

    ///
    alias off_t fpos_t;

    ///
    struct __sFILE
    {
        ubyte*          _p;
        int             _r;
        int             _w;
        short           _flags;
        short           _file;
        __sbuf          _bf;
        int             _lbfsize;

        void*           _cookie;
        int     function(void*)                 _close;
        int     function(void*, char*, int)     _read;
        fpos_t  function(void*, fpos_t, int)    _seek;
        int     function(void*, in char*, int)  _write;

        __sbuf          _ub;
        ubyte*          _up;
        int             _ur;

        ubyte[3]        _ubuf;
        ubyte[1]        _nbuf;

        __sbuf          _lb;

        int             _blksize;
        fpos_t          _offset;

        pthread_mutex_t _fl_mutex;
        pthread_t       _fl_owner;
        int             _fl_count;
        int             _orientation;
        mbstate_t       _mbstate;
    }

    ///
    alias __sFILE _iobuf;
    ///
    alias shared(__sFILE) FILE;
}
else version (NetBSD)
{
    ///
    alias off_t fpos_t;

    ///
    struct __sFILE
    {
        ubyte*          _p;
        int             _r;
        int             _w;
        ushort           _flags;
        short           _file;
        __sbuf          _bf;
        int             _lbfsize;

        void*           _cookie;
        int     function(void*)                 _close;
        ssize_t     function(void*, char*, size_t)     _read;
        fpos_t  function(void*, fpos_t, int)    _seek;
        ssize_t     function(void*, in char*, size_t)  _write;

        __sbuf          _ub;
        ubyte*          _up;
        int             _ur;

        ubyte[3]        _ubuf;
        ubyte[1]        _nbuf;

        int     function(void *)    _flush;
        /* Formerly used by fgetln/fgetwln; kept for binary compatibility */
        char[__sbuf.sizeof - _flush.sizeof]    _lb_unused = void;


        int             _blksize;
        off_t          _offset;
        static assert(off_t.sizeof==8);
    }

    ///
    alias __sFILE _iobuf;
    ///
    alias shared(__sFILE) FILE;
}
else version (OpenBSD)
{
    ///
    alias fpos_t = off_t;

    ///
    struct __sFILE
    {
        ubyte*          _p;
        int             _r;
        int             _w;
        short           _flags;
        short           _file;
        __sbuf          _bf;
        int             _lbfsize;

        void*           _cookie;
        int     function(void*)                         _close;
        int     function(void*, scope char*, int)       _read;
        fpos_t  function(void*, fpos_t, int)            _seek;
        int     function(void*, scope const char*, int) _write;

        __sbuf          _ext;
        ubyte*          _up;
        int             _ur;

        ubyte[3]        _ubuf;
        ubyte[1]        _nbuf;

        __sbuf          _lb;

        int             _blksize;
        fpos_t          _offset;
    }

    ///
    alias __sFILE _iobuf;
    ///
    alias shared(__sFILE) FILE;
}
else version (DragonFlyBSD)
{
    alias off_t fpos_t;

    /// See /usr/include/stdio.h
    struct __FILE_public
    {
        ubyte*          *_p;            /* current position in (some) buffer */
        int             _flags;         /* flags, below; this FILE is free if 0 */
        int             _fileno;        /* fileno, if Unix descriptor, else -1 */
        ssize_t         _r;             /* read space left for getc() */
        ssize_t         _w;             /* write space left for putc() */
        ssize_t         _lbfsize;       /* 0 or -_bf._size, for inline putc */
    }

    alias __FILE_public _iobuf;
    alias shared(__FILE_public) FILE;
}
else version (Solaris)
{
    import core.stdc.wchar_ : mbstate_t;

    ///
    alias c_long fpos_t;

    version (D_LP64)
    {
        ///
        struct _iobuf
        {
            char*      _ptr;   /* next character from/to here in buffer */
            char*      _base;  /* the buffer */
            char*      _end;   /* the end of the buffer */
            size_t     _cnt;   /* number of available characters in buffer */
            int        _file;  /* UNIX System file descriptor */
            int        _flag;  /* the state of the stream */
            ubyte[24]  _lock;  //rmutex_t   _lock; /* lock for this structure */
            mbstate_t  _state; /* mbstate_t */
            ubyte[32]  __fill; /* filler to bring size to 128 bytes */
        }
    }
    else
    {
        ///
        struct _iobuf
        {
            char* _ptr;
            int _cnt;
            char* _base;
            char _flag = 0;
            char _magic = 0;
            ushort __flags; // __orientation:2
                            // __ionolock:1
                            // __seekable:1
                            // __extendedfd:1
                            // __xf_nocheck:1
                            // __filler:10
        }
    }
    ///
    alias shared(_iobuf) FILE;
}
else version (CRuntime_Bionic)
{
    import core.sys.posix.sys.types : off_t;
    ///
    alias off_t fpos_t;

    ///
    struct __sFILE
    {
        ubyte*    _p;
        int       _r;
        int       _w;
        short     _flags;
        short     _file;
        __sbuf    _bf;
        int       _lbfsize;

        void*     _cookie;
        int      function(void*)                          _close;
        int      function(void*, scope char*, int)        _read;
        fpos_t   function(void*, fpos_t, int)             _seek;
        int      function(void*, scope const char*, int)  _write;

        __sbuf    _ext;
        ubyte*    _up;
        int       _ur;

        ubyte[3]  _ubuf;
        ubyte[1]  _nbuf;

        __sbuf    _lb;

        int       _blksize;
        fpos_t    _offset;
    }

    ///
    alias __sFILE _iobuf;
    ///
    alias shared(__sFILE) FILE;
}
else version (CRuntime_UClibc)
{
    import core.stdc.wchar_ : mbstate_t;
    import core.stdc.stddef : wchar_t;
    import core.sys.posix.sys.types : ssize_t, pthread_mutex_t;

    alias long off_t;

    ///
    struct fpos_t
    {
        off_t __pos;
        mbstate_t __state;
        int __mblen_pending;
    }

    struct _IO_cookie_io_functions_t
    {
       ssize_t function(void* __cookie, char* __buf, size_t __bufsize)          read;
       ssize_t function(void* __cookie, const char* __buf, size_t __bufsize)    write;
       int function(void* __cookie, off_t* __pos, int __whence)                 seek;
       int function(void* __cookie)                                             close;
    }

    alias _IO_cookie_io_functions_t cookie_io_functions_t;

    ///
    struct __STDIO_FILE_STRUCT
    {
        ushort __modeflags;
        char[2] __ungot_width = 0;
        int __filedes;
        char* __bufstart;
        char* __bufend;
        char* __bufpos;
        char* __bufread;
        char* __bufgetc_u;
        char*__bufputc_u;
        __STDIO_FILE_STRUCT* __nextopen;
        void *__cookie;
        _IO_cookie_io_functions_t __gcs;
        wchar_t[2] __ungot = 0;
        mbstate_t __state;
        void *__unused;
        int __user_locking;
        pthread_mutex_t __lock;
    }

    ///
    alias __STDIO_FILE_STRUCT _iobuf;
    ///
    alias shared(__STDIO_FILE_STRUCT) FILE;
}
else
{
    static assert( false, "Unsupported platform" );
}

enum
{
    ///
    _F_RDWR = 0x0003, // non-standard
    ///
    _F_READ = 0x0001, // non-standard
    ///
    _F_WRIT = 0x0002, // non-standard
    ///
    _F_BUF  = 0x0004, // non-standard
    ///
    _F_LBUF = 0x0008, // non-standard
    ///
    _F_ERR  = 0x0010, // non-standard
    ///
    _F_EOF  = 0x0020, // non-standard
    ///
    _F_BIN  = 0x0040, // non-standard
    ///
    _F_IN   = 0x0080, // non-standard
    ///
    _F_OUT  = 0x0100, // non-standard
    ///
    _F_TERM = 0x0200, // non-standard
}

version (CRuntime_DigitalMars)
{
    enum
    {
        ///
        _IOFBF   = 0,
        ///
        _IOLBF   = 0x40,
        ///
        _IONBF   = 4,
        ///
        _IOREAD  = 1,     // non-standard
        ///
        _IOWRT   = 2,     // non-standard
        ///
        _IOMYBUF = 8,     // non-standard
        ///
        _IOEOF   = 0x10,  // non-standard
        ///
        _IOERR   = 0x20,  // non-standard
        ///
        _IOSTRG  = 0x40,  // non-standard
        ///
        _IORW    = 0x80,  // non-standard
        ///
        _IOTRAN  = 0x100, // non-standard
        ///
        _IOAPP   = 0x200, // non-standard
    }

    extern shared void function() _fcloseallp;

    private extern shared FILE[_NFILE] _iob;

    ///
    enum stdin  = &_iob[0];
    ///
    enum stdout = &_iob[1];
    ///
    enum stderr = &_iob[2];
    ///
    enum stdaux = &_iob[3];
    ///
    enum stdprn = &_iob[4];
}
else version (CRuntime_Microsoft)
{
    enum
    {
        ///
        _IOFBF   = 0,
        ///
        _IOLBF   = 0x40,
        ///
        _IONBF   = 4,
        /// Removed since Visual Studio 2015.
        _IOREAD  = 1,     // non-standard
        /// Removed since Visual Studio 2015.
        _IOWRT   = 2,     // non-standard
        /// Removed since Visual Studio 2015.
        _IOMYBUF = 8,     // non-standard
        /// Removed since Visual Studio 2015.
        _IOEOF   = 0x10,  // non-standard
        /// Removed since Visual Studio 2015.
        _IOERR   = 0x20,  // non-standard
        /// Removed since Visual Studio 2015.
        _IOSTRG  = 0x40,  // non-standard
        /// Removed since Visual Studio 2015.
        _IORW    = 0x80,  // non-standard
        /// Removed since Visual Studio 2015.
        _IOAPP   = 0x200, // non-standard
        /// Removed since Visual Studio 2015.
        _IOAPPEND = 0x200, // non-standard
    }

    extern shared void function() _fcloseallp;

    ///
    shared FILE* stdin;  // = &__iob_func()[0];
    ///
    shared FILE* stdout; // = &__iob_func()[1];
    ///
    shared FILE* stderr; // = &__iob_func()[2];
}
else version (CRuntime_Glibc)
{
    enum
    {
        ///
        _IOFBF = 0,
        ///
        _IOLBF = 1,
        ///
        _IONBF = 2,
    }

    ///
    extern shared FILE* stdin;
    ///
    extern shared FILE* stdout;
    ///
    extern shared FILE* stderr;
}
else version (Darwin)
{
    enum
    {
        ///
        _IOFBF = 0,
        ///
        _IOLBF = 1,
        ///
        _IONBF = 2,
    }

    private extern(C) shared FILE* __stdinp;
    private extern(C) shared FILE* __stdoutp;
    private extern(C) shared FILE* __stderrp;

    ///
    alias __stdinp  stdin;
    ///
    alias __stdoutp stdout;
    ///
    alias __stderrp stderr;
}
else version (FreeBSD)
{
    enum
    {
        ///
        _IOFBF = 0,
        ///
        _IOLBF = 1,
        ///
        _IONBF = 2,
    }

    private extern shared FILE* __stdinp;
    private extern shared FILE* __stdoutp;
    private extern shared FILE* __stderrp;

    ///
    alias __stdinp  stdin;
    ///
    alias __stdoutp stdout;
    ///
    alias __stderrp stderr;
}
else version (NetBSD)
{
    enum
    {
        ///
        _IOFBF = 0,
        ///
        _IOLBF = 1,
        ///
        _IONBF = 2,
    }

    private extern __gshared FILE[3] __sF;
    @property auto __stdin()() { return &__sF[0]; }
    @property auto __stdout()() { return &__sF[1]; }
    @property auto __stderr()() { return &__sF[2]; }
    ///
    alias __stdin stdin;
    ///
    alias __stdout stdout;
    ///
    alias __stderr stderr;
}
else version (OpenBSD)
{
    enum
    {
        ///
        _IOFBF = 0,
        ///
        _IOLBF = 1,
        ///
        _IONBF = 2,
    }

    private extern __gshared FILE[3] __sF;
    @property auto __stdin()() { return &__sF[0]; }
    @property auto __stdout()() { return &__sF[1]; }
    @property auto __stderr()() { return &__sF[2]; }
    ///
    alias __stdin stdin;
    ///
    alias __stdout stdout;
    ///
    alias __stderr stderr;
}
else version (DragonFlyBSD)
{
    enum
    {
        _IOFBF = 0,
        _IOLBF = 1,
        _IONBF = 2,
    }

    private extern shared FILE* __stdinp;
    private extern shared FILE* __stdoutp;
    private extern shared FILE* __stderrp;

    alias __stdinp  stdin;
    alias __stdoutp stdout;
    alias __stderrp stderr;
}
else version (Solaris)
{
    enum
    {
        ///
        _IOFBF = 0x00,
        ///
        _IOLBF = 0x40,
        ///
        _IONBF = 0x04,
        ///
        _IOEOF = 0x20,
        ///
        _IOERR = 0x40,
        ///
        _IOREAD = 0x01,
        ///
        _IOWRT = 0x02,
        ///
        _IORW = 0x80,
        ///
        _IOMYBUF = 0x08,
    }

    private extern shared FILE[_NFILE] __iob;

    ///
    shared stdin = &__iob[0];
    ///
    shared stdout = &__iob[1];
    ///
    shared stderr = &__iob[2];
}
else version (CRuntime_Bionic)
{
    enum
    {
        ///
        _IOFBF = 0,
        ///
        _IOLBF = 1,
        ///
        _IONBF = 2,
    }

    private extern shared FILE[3] __sF;

    ///
    shared stdin  = &__sF[0];
    ///
    shared stdout = &__sF[1];
    ///
    shared stderr = &__sF[2];
}
else version (Linux_Musl)
{
    // needs tail const
    __gshared FILE* stdin;
    ///
    extern __gshared FILE* stdout;
    ///
    __gshared FILE* stderr;
    enum
    {
        ///
        _IOFBF = 0,
        ///
        _IOLBF = 1,
        ///
        _IONBF = 2,
    }
}
else version (CRuntime_UClibc)
{
    enum
    {
        ///
        _IOFBF = 0,
        ///
        _IOLBF = 1,
        ///
        _IONBF = 2,
    }

    ///
    extern shared FILE* stdin;
    ///
    extern shared FILE* stdout;
    ///
    extern shared FILE* stderr;
}
else
{
    static assert( false, "Unsupported platform" );
}

///
int remove(scope const char* filename);
///
int rename(scope const char* from, scope const char* to);

///
@trusted FILE* tmpfile(); // No unsafe pointer manipulation.
///
char* tmpnam(char* s);

///
int   fclose(FILE* stream);

// No unsafe pointer manipulation.
@trusted
{
    ///
    int   fflush(FILE* stream);
}

///
FILE* fopen(scope const char* filename, scope const char* mode);
///
FILE* freopen(scope const char* filename, scope const char* mode, FILE* stream);

///
void setbuf(FILE* stream, char* buf);
///
int  setvbuf(FILE* stream, char* buf, int mode, size_t size);

version (MinGW)
{
    // Prefer the MinGW versions over the MSVC ones, as the latter don't handle
    // reals at all.
    ///
    int __mingw_fprintf(FILE* stream, scope const char* format, ...);
    ///
    alias __mingw_fprintf fprintf;

    ///
    int __mingw_fscanf(FILE* stream, scope const char* format, ...);
    ///
    alias __mingw_fscanf fscanf;

    ///
    int __mingw_sprintf(scope char* s, scope const char* format, ...);
    ///
    alias __mingw_sprintf sprintf;

    ///
    int __mingw_sscanf(scope const char* s, scope const char* format, ...);
    ///
    alias __mingw_sscanf sscanf;

    ///
    int __mingw_vfprintf(FILE* stream, scope const char* format, va_list arg);
    ///
    alias __mingw_vfprintf vfprintf;

    ///
    int __mingw_vfscanf(FILE* stream, scope const char* format, va_list arg);
    ///
    alias __mingw_vfscanf vfscanf;

    ///
    int __mingw_vsprintf(scope char* s, scope const char* format, va_list arg);
    ///
    alias __mingw_vsprintf vsprintf;

    ///
    int __mingw_vsscanf(scope const char* s, scope const char* format, va_list arg);
    ///
    alias __mingw_vsscanf vsscanf;

    ///
    int __mingw_vprintf(scope const char* format, va_list arg);
    ///
    alias __mingw_vprintf vprintf;

    ///
    int __mingw_vscanf(scope const char* format, va_list arg);
    ///
    alias __mingw_vscanf vscanf;

    ///
    int __mingw_printf(scope const char* format, ...);
    ///
    alias __mingw_printf printf;

    ///
    int __mingw_scanf(scope const char* format, ...);
    ///
    alias __mingw_scanf scanf;
}
else
{
    ///
    int fprintf(FILE* stream, scope const char* format, ...)
    {
        //stub
        return 0;
    }
    ///
    int fscanf(FILE* stream, scope const char* format, ...);
    ///
    int sprintf(scope char* s, scope const char* format, ...);
    ///
    int sscanf(scope const char* s, scope const char* format, ...)
    {
        //stub
        return 0;
    }
    ///
    int vfprintf(FILE* stream, scope const char* format, va_list arg);
    ///
    int vfscanf(FILE* stream, scope const char* format, va_list arg);
    ///
    int vsprintf(scope char* s, scope const char* format, va_list arg);
    ///
    int vsscanf(scope const char* s, scope const char* format, va_list arg);
    ///
    int vprintf(scope const char* format, va_list arg);
    ///
    int vscanf(scope const char* format, va_list arg);
    ///
    int printf(scope const char* format, ...);
    ///
    int scanf(scope const char* format, ...);
}

// No unsafe pointer manipulation.
@trusted
{
    ///
    int fgetc(FILE* stream);
    ///
    //int fputc(int c, FILE* stream);
}

//https://github.com/unofficial-opensource-apple/Libc/blob/aec41eec4ba22ce5873263632f3724b4be89bd5e/stdio/FreeBSD/rget.c
version (Darwin) {
    int __srget(FILE *fp)
    {
        if (__srefill(fp) == 0) {
            fp._r--;
            return (*fp._p++);
        }
        return (EOF);
    }
//https://github.com/unofficial-opensource-apple/Libc/blob/aec41eec4ba22ce5873263632f3724b4be89bd5e/include/stdio.h#L395
    int __sgetc(FILE *f)
    {
        return --f._r < 0 ? __srget(f) : cast(int)(*f._p++);
    }

    int getc_unlocked(FILE *f)
    {
        return __sgetc(f);
    }
}
version (Linux_Musl) { //musl
    import stdio.__towrite;
    nothrow:
    int __toread(FILE *f)
    {
        int mode = f.mode | f.mode - 1;
	    f.mode = mode;
	    if (f.wpos != f.wbase) f.write(f, cast(const(ubyte*))0, cast(ulong)0);
	    f.wpos = f.wbase = f.wend = cast(ubyte*)0;
	    if (f.flags & F_NORD) {
	        int flags = f.flags | F_ERR;
		    f.flags = flags;
		    return EOF;
	    }
	    f.rpos = f.rend = f.buf + f.buf_size;
	    return (f.flags & F_EOF) ? EOF : 0;
    }

    nothrow:
    int __uflow(FILE *f)
    {
	    ubyte c;
	    if (!__toread(f) && f.read(f, &c, 1)==1) return c;
	    return EOF;
    }

    int __overflow(FILE *f, int _c)
    {
        ubyte c = cast(ubyte)_c;

        if (!f.wend && __towrite(f)) return EOF;
        if (f.wpos != f.wend && c != f.lbf) {
            auto next = f.wpos + 1;
            f.wpos = next;
            return *f.wpos = c;
        }
        if (f.write(f, &c, 1) != 1) return EOF;
        return c;
    }

    extern(C) int getc_unlocked(FILE *f)
    {
        if (f.rpos != f.rend) {
            *(f).rpos = cast(ubyte)(*(f).rpos + 1);
            return *(f).rpos;
        }
        return __uflow(f);
    }

    int fputc(int c, FILE *f)
    {
        return do_putc(c, f);
    }

    static int do_putc(int c, FILE *f)
    {
        return putc_unlocked(c, f);
    }

    static int putc_unlocked(int c, FILE *f)
    {
        if ((cast(ubyte)c != f.lbf) && (f.wpos != f.wend)) {
            auto next = f.wpos + 1;
            f.wpos = next;
            return *f.wpos = cast(ubyte)c;
        } else {
            return __overflow(f, cast(ubyte)c);
        }
    }
}
//musl
static wint_t __fgetwc_unlocked_internal(FILE *f)
{
    wchar_t wc;
    int c;
    size_t l;

    /* Convert character from buffer if possible */
    //if (f.rpos != f.rend) {
    //    l = mbtowc(&wc, cast(void *)f.rpos, f.rend - f.rpos);
    //    if (l+1 >= 1) {
    //        f.rpos += l + !l; /* l==0 means 1 byte, null */
    //        return wc;
    //    }
    //}

    /* Convert character byte-by-byte */
    mbstate_t st = cast(mbstate_t)0;
    ubyte b;
    int first = 1;
    do {
        c = getc_unlocked(f);
        b = cast(ubyte)c;
        if (c < 0) {
            //TODO: fix errno if (!first) errno = EILSEQ;
            return WEOF;
        }
        l = mbrtowc(&wc, cast(const char *)&b, 1, &st);
        if (l == -1) {
            if (!first) ungetc(b, f);
            return WEOF;
        }
        first = 0;
    } while (l == -2);

    return wc;
}
//musl
wint_t __fgetwc_unlocked(FILE *f)
{
    shared(locale_t*) ploc = &CURRENT_LOCALE;
    shared(locale_t) loc = *ploc;
    if (f.mode <= 0) fwide(f, 1);
    *ploc = f.locale;
    wchar_t wc = __fgetwc_unlocked_internal(f);
    *ploc = loc;
    return wc;
}
//musl
wint_t fgetwc(FILE* fp)
{
    wint_t c;
    //TODO FLOCK(f);
    c = __fgetwc_unlocked(fp);
    //TODO FUNLOCK(f);
    return c;
}

///
char* fgets(char* s, int n, FILE* stream);
///
int   fputs(scope const char* s, FILE* stream)
{
    //stub
    return 0;
}
///
char* gets(char* s);
///
int   puts(scope const char* s)
{
    //stub
    return 0;
}

// No unsafe pointer manipulation.
extern (D) @trusted
{
    ///
    int getchar()()                 { return getc(stdin);     }
    ///
    int putchar()(int c)            { return putc(c,stdout);  }
    ///
    int getc()(FILE* stream)        { return fgetc(stream);   }
    ///
    int putc()(int c, FILE* stream) { return fputc(c,stream); }
}

///
@trusted int ungetc(int c, FILE* stream); // No unsafe pointer manipulation.

///
size_t fread(scope void* ptr, size_t size, size_t nmemb, FILE* stream);
///
size_t fwrite(scope const void* ptr, size_t size, size_t nmemb, FILE* stream)
{
    //stub
    return 0;
}

// No unsafe pointer manipulation.
@trusted
{
    ///
    int fgetpos(FILE* stream, scope fpos_t * pos);
    ///
    int fsetpos(FILE* stream, scope const fpos_t* pos);

    ///
    int    fseek(FILE* stream, c_long offset, int whence);
    ///
    c_long ftell(FILE* stream);
}

version (CRuntime_DigitalMars)
{
  // No unsafe pointer manipulation.
  extern (D) @trusted
  {
    ///
    void rewind()(FILE* stream)   { fseek(stream,0L,SEEK_SET); stream._flag= stream._flag & ~_IOERR; }
    ///
    pure void clearerr()(FILE* stream) { stream._flag = stream._flag & ~(_IOERR|_IOEOF); }
    ///
    pure int  feof()(FILE* stream)     { return stream._flag&_IOEOF; }
    ///
    pure int  ferror()(FILE* stream)   { return stream._flag&_IOERR; }
    ///
    pure int  fileno()(FILE* stream)   { return stream._file; }
  }
  ///
    int   _snprintf(scope char* s, size_t n, scope const char* fmt, ...);
    ///
    alias _snprintf snprintf;

    ///
    int   _vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
    ///
    alias _vsnprintf vsnprintf;
}
else version (CRuntime_Microsoft)
{
  // No unsafe pointer manipulation.
  @trusted
  {
    ///
    void rewind(FILE* stream);
    ///
    pure void clearerr(FILE* stream);
    ///
    pure int  feof(FILE* stream);
    ///
    pure int  ferror(FILE* stream);
    ///
    pure int  fileno(FILE* stream);
  }

  version (MinGW)
  {
    int   __mingw_snprintf(scope char* s, size_t n, scope const char* fmt, ...);
    ///
    alias __mingw_snprintf _snprintf;
    ///
    alias __mingw_snprintf snprintf;

    ///
    int   __mingw_vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
    ///
    alias __mingw_vsnprintf _vsnprintf;
    ///
    alias __mingw_vsnprintf vsnprintf;
  }
  else
  {
    ///
    int _snprintf(scope char* s, size_t n, scope const char* format, ...);
    ///
    int  snprintf(scope char* s, size_t n, scope const char* format, ...);

    ///
    int _vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
    ///
    int  vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
  }

    ///
    int _fputc_nolock(int c, FILE *fp);
    ///
    int _fgetc_nolock(FILE *fp);

    ///
    int _lock_file(FILE *fp);
    ///
    int _unlock_file(FILE *fp);

    ///
    intptr_t _get_osfhandle(int fd);
    ///
    int _open_osfhandle(intptr_t osfhandle, int flags);
}
else version (CRuntime_Glibc)
{
  // No unsafe pointer manipulation.
  @trusted
  {
    ///
    void rewind(FILE* stream);
    ///
    pure void clearerr(FILE* stream);
    ///
    pure int  feof(FILE* stream);
    ///
    pure int  ferror(FILE* stream);
    ///
    int  fileno(FILE *);
  }

    ///
    int  snprintf(scope char* s, size_t n, scope const char* format, ...);
    ///
    int  vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
}
else version (Darwin)
{
  // No unsafe pointer manipulation.
  @trusted
  {
    ///
    void rewind(FILE*);
    ///
    pure void clearerr(FILE*);
    ///
    pure int  feof(FILE*);
    ///
    pure int  ferror(FILE*);
    ///
    int  fileno(FILE*);
  }

    ///
    int  snprintf(scope char* s, size_t n, scope const char* format, ...);
    ///
    int  vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);

    //https://github.com/unofficial-opensource-apple/Libc/blob/aec41eec4ba22ce5873263632f3724b4be89bd5e/stdio/FreeBSD/refill.c#L154
    int __srefill0(FILE *fp)
    {

        /* make sure stdio is set up */
        pthread_once(&__sdidinit, __sinit);

        ORIENT(fp, -1);

        fp._r = 0;     /* largely a convenience for callers */

        /* SysV does not make this test; take it out for compatibility */
        if (fp._flags & __SEOF)
            return (EOF);

        /* if not already reading, have to be reading and writing */
        if ((fp._flags & __SRD) == 0) {
            if ((fp._flags & __SRW) == 0) {
                errno = EBADF;
                fp._flags |= __SERR;
                return (EOF);
            }
            /* switch to reading */
            if (fp._flags & __SWR) {
                if (__sflush(fp))
                    return (EOF);
                fp._flags &= ~__SWR;
                fp._w = 0;
                fp._lbfsize = 0;
            }
            fp._flags |= __SRD;
        } else {
            /*
             * We were reading.  If there is an ungetc buffer,
             * we must have been reading from that.  Drop it,
             * restoring the previous buffer (if any).  If there
             * is anything in that buffer, return.
             */
            if (HASUB(fp)) {
                FREEUB(fp);
                if ((fp._r = fp._ur) != 0) {
                    fp._p = fp._up;
                    return (0);
                }
            }
        }

        if (fp._bf._base == NULL)
            __smakebuf(fp);

        /*
         * Before reading from a line buffered or unbuffered file,
         * flush all line buffered output files, per the ANSI C
         * standard.
         */
        if (fp._flags & (__SLBF|__SNBF)) {
            /* Ignore this file in _fwalk to avoid potential deadlock. */
            fp._flags |= __SIGN;
            cast(void) _fwalk(lflush);
            fp._flags &= ~__SIGN;

            /* Now flush this file without locking it. */
            if ((fp_flags & (__SLBF|__SWR)) == (__SLBF|__SWR))
                __sflush(fp);
        }
        return (1);
    }

    //https://github.com/unofficial-opensource-apple/Libc/blob/aec41eec4ba22ce5873263632f3724b4be89bd5e/stdio/FreeBSD/refill.c#L154
    int __srefill(FILE *fp)
    {
        int ret;

        if ((ret = __srefill0(fp)) <= 0)
            return ret;
        return __srefill1(fp);
    }
}
else version (FreeBSD)
{
  // No unsafe pointer manipulation.
  @trusted
  {
    ///
    void rewind(FILE*);
    ///
    pure void clearerr(FILE*);
    ///
    pure int  feof(FILE*);
    ///
    pure int  ferror(FILE*);
    ///
    int  fileno(FILE*);
  }

    ///
    int  snprintf(scope char* s, size_t n, scope const char* format, ...);
    ///
    int  vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
}
else version (NetBSD)
{
  // No unsafe pointer manipulation.
  @trusted
  {
    ///
    void rewind(FILE*);
    ///
    pure void clearerr(FILE*);
    ///
    pure int  feof(FILE*);
    ///
    pure int  ferror(FILE*);
    ///
    int  fileno(FILE*);
  }

    ///
    int  snprintf(char* s, size_t n, in char* format, ...);
    ///
    int  vsnprintf(char* s, size_t n, in char* format, va_list arg);
}
else version (OpenBSD)
{
    // No unsafe pointer manipulation.
    @trusted
    {
        ///
        void rewind(FILE*);
    }
    @trusted private
    {
        ///
        pragma(mangle, "clearerr")
        pure void __clearerr(FILE*);
        ///
        pragma(mangle, "feof")
        pure int __feof(FILE*);
        ///
        pragma(mangle, "ferror")
        pure int __ferror(FILE*);
        ///
        pragma(mangle, "fileno")
        int __fileno(FILE*);
    }

    enum __SLBF = 0x0001;
    enum __SNBF = 0x0002;
    enum __SRD  = 0x0004;
    enum __SWR  = 0x0008;
    enum __SRW  = 0x0010;
    enum __SEOF = 0x0020;
    enum __SERR = 0x0040;
    enum __SMBF = 0x0080;
    enum __SAPP = 0x0100;
    enum __SSTR = 0x0200;
    enum __SOPT = 0x0400;
    enum __SNPT = 0x0800;
    enum __SOFF = 0x1000;
    enum __SMOD = 0x2000;
    enum __SALC = 0x4000;
    enum __SIGN = 0x8000;

    extern immutable __gshared int __isthreaded;

    extern (D) @trusted
    {
        void __sclearerr()(FILE* p)
        {
            p._flags &= ~(__SERR|__SEOF);
        }

        int __sfeof()(FILE* p)
        {
            return (p._flags & __SEOF) != 0;
        }

        int __sferror()(FILE* p)
        {
            return (p._flags & __SERR) != 0;
        }

        int __sfileno()(FILE* p)
        {
            return p._file;
        }

        pure void clearerr()(FILE* file)
        {
            !__isthreaded ? __sclearerr(file) : __clearerr(file);
        }

        pure int feof()(FILE* file)
        {
            return !__isthreaded ? __sfeof(file) : __feof(file);
        }

        pure int ferror()(FILE* file)
        {
            return !__isthreaded ? __sferror(file) : __ferror(file);
        }

        int fileno()(FILE* file)
        {
            return !__isthreaded ? __sfileno(file) : __fileno(file);
        }
    }

    ///
    int  snprintf(scope char* s, size_t n, scope const char* format, ...);
    ///
    int  vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
}
else version (DragonFlyBSD)
{
  // No unsafe pointer manipulation.
  @trusted
  {
    void rewind(FILE*);
    pure void clearerr(FILE*);
    pure int  feof(FILE*);
    pure int  ferror(FILE*);
    int  fileno(FILE*);
  }
  enum __SLBF = 0x0001;
  enum __SNBF = 0x0002;
  enum __SRD  = 0x0004;
  enum __SWR  = 0x0008;
  enum __SRW  = 0x0010;
  enum __SEOF = 0x0020;
  enum __SERR = 0x0040;
  enum __SMBF = 0x0080;
  enum __SAPP = 0x0100;
  enum __SSTR = 0x0200;
  enum __SOPT = 0x0400;
  enum __SNPT = 0x0800;
  enum __SOFF = 0x1000;
  enum __SMOD = 0x2000;
  enum __SALC = 0x4000;
  enum __SIGN = 0x8000;

  int  snprintf(scope char* s, size_t n, scope const char* format, ...);
  int  vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
}
else version (Solaris)
{
  // No unsafe pointer manipulation.
  @trusted
  {
    ///
    void rewind(FILE*);
    ///
    pure void clearerr(FILE*);
    ///
    pure int  feof(FILE*);
    ///
    pure int  ferror(FILE*);
    ///
    int  fileno(FILE*);
  }

    ///
    int  snprintf(scope char* s, size_t n, scope const char* format, ...);
    ///
    int  vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
}
else version (CRuntime_Bionic)
{
  // No unsafe pointer manipulation.
  @trusted
  {
    ///
    void rewind(FILE*);
    ///
    pure void clearerr(FILE*);
    ///
    pure int  feof(FILE*);
    ///
    pure int  ferror(FILE*);
    ///
    int  fileno(FILE*);
  }

  ///
    int  snprintf(scope char* s, size_t n, scope const char* format, ...);
    ///
    int  vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
}
else version (Linux_Musl)
{
    @trusted
    {
        ///
        void rewind(FILE* stream);
        ///
        pure void clearerr(FILE* stream);
        ///
        pure int  feof(FILE* stream);
        ///
        pure int  ferror(FILE* stream);
        ///
        int  fileno(FILE *);
    }

    ///
    int snprintf(scope char* s, size_t n, scope const char* format, ...);
    ///
    int vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
}
else version (CRuntime_UClibc)
{
  // No unsafe pointer manipulation.
  @trusted
  {
    ///
    void rewind(FILE* stream);
    ///
    pure void clearerr(FILE* stream);
    ///
    pure int  feof(FILE* stream);
    ///
    pure int  ferror(FILE* stream);
    ///
    int  fileno(FILE *);
  }

    ///
    int  snprintf(scope char* s, size_t n, scope const char* format, ...);
    ///
    int  vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
}
else
{
    static assert( false, "Unsupported platform" );
}

///
void perror(scope const char* s);

version (CRuntime_DigitalMars)
{
    version (none)
        import core.sys.windows.windows : HANDLE, _WaitSemaphore, _ReleaseSemaphore;
    else
    {
        // too slow to import windows
        private alias void* HANDLE;
        private void _WaitSemaphore(int iSemaphore);
        private void _ReleaseSemaphore(int iSemaphore);
    }

    enum
    {
        ///
        FHND_APPEND     = 0x04,
        ///
        FHND_DEVICE     = 0x08,
        ///
        FHND_TEXT       = 0x10,
        ///
        FHND_BYTE       = 0x20,
        ///
        FHND_WCHAR      = 0x40,
    }

    private enum _MAX_SEMAPHORES = 10 + _NFILE;
    private enum _semIO = 3;

    private extern __gshared short[_MAX_SEMAPHORES] _iSemLockCtrs;
    private extern __gshared int[_MAX_SEMAPHORES] _iSemThreadIds;
    private extern __gshared int[_MAX_SEMAPHORES] _iSemNestCount;
    private extern __gshared HANDLE[_NFILE] _osfhnd;
    extern shared ubyte[_NFILE] __fhnd_info;

    // this is copied from semlock.h in DMC's runtime.
    private void LockSemaphore()(uint num)
    {
        asm nothrow @nogc
        {
            mov EDX, num;
            lock;
            inc _iSemLockCtrs[EDX * 2];
            jz lsDone;
            push EDX;
            call _WaitSemaphore;
            add ESP, 4;
        }

    lsDone: {}
    }

    // this is copied from semlock.h in DMC's runtime.
    private void UnlockSemaphore()(uint num)
    {
        asm nothrow @nogc
        {
            mov EDX, num;
            lock;
            dec _iSemLockCtrs[EDX * 2];
            js usDone;
            push EDX;
            call _ReleaseSemaphore;
            add ESP, 4;
        }

    usDone: {}
    }

    // This converts a HANDLE to a file descriptor in DMC's runtime
    ///
    int _handleToFD()(HANDLE h, int flags)
    {
        LockSemaphore(_semIO);
        scope(exit) UnlockSemaphore(_semIO);

        foreach (fd; 0 .. _NFILE)
        {
            if (!_osfhnd[fd])
            {
                _osfhnd[fd] = h;
                __fhnd_info[fd] = cast(ubyte)flags;
                return fd;
            }
        }

        return -1;
    }

    ///
    HANDLE _fdToHandle()(int fd)
    {
        // no semaphore is required, once inserted, a file descriptor
        // doesn't change.
        if (fd < 0 || fd >= _NFILE)
            return null;

        return _osfhnd[fd];
    }

    enum
    {
        ///
        STDIN_FILENO  = 0,
        ///
        STDOUT_FILENO = 1,
        ///
        STDERR_FILENO = 2,
    }

    int open(scope const(char)* filename, int flags, ...); ///
    alias _open = open; ///
    int _wopen(scope const wchar* filename, int oflag, ...); ///
    int sopen(scope const char* filename, int oflag, int shflag, ...); ///
    alias _sopen = sopen; ///
    int _wsopen(scope const wchar* filename, int oflag, int shflag, ...); ///
    int close(int fd); ///
    alias _close = close; ///
    FILE *fdopen(int fd, scope const(char)* flags); ///
    alias _fdopen = fdopen; ///
    FILE *_wfdopen(int fd, scope const(wchar)* flags); ///

}
else version (CRuntime_Microsoft)
{
    int _open(scope const char* filename, int oflag, ...); ///
    int _wopen(scope const wchar* filename, int oflag, ...); ///
    int _sopen(scope const char* filename, int oflag, int shflag, ...); ///
    int _wsopen(scope const wchar* filename, int oflag, int shflag, ...); ///
    int _close(int fd); ///
    FILE *_fdopen(int fd, scope const(char)* flags); ///
    FILE *_wfdopen(int fd, scope const(wchar)* flags); ///
}

version (Windows)
{
    // file open flags
    enum
    {
        _O_RDONLY = 0x0000, ///
        O_RDONLY = _O_RDONLY, ///
        _O_WRONLY = 0x0001, ///
        O_WRONLY = _O_WRONLY, ///
        _O_RDWR   = 0x0002, ///
        O_RDWR = _O_RDWR, ///
        _O_APPEND = 0x0008, ///
        O_APPEND = _O_APPEND, ///
        _O_CREAT  = 0x0100, ///
        O_CREAT = _O_CREAT, ///
        _O_TRUNC  = 0x0200, ///
        O_TRUNC = _O_TRUNC, ///
        _O_EXCL   = 0x0400, ///
        O_EXCL = _O_EXCL, ///
        _O_TEXT   = 0x4000, ///
        O_TEXT = _O_TEXT, ///
        _O_BINARY = 0x8000, ///
        O_BINARY = _O_BINARY, ///
    }

    enum
    {
        _S_IREAD  = 0x0100, /// read permission, owner
        S_IREAD = _S_IREAD, /// read permission, owner
        _S_IWRITE = 0x0080, /// write permission, owner
        S_IWRITE = _S_IWRITE, /// write permission, owner
    }

    enum
    {
        _SH_DENYRW = 0x10, /// deny read/write mode
        SH_DENYRW = _SH_DENYRW, /// deny read/write mode
        _SH_DENYWR = 0x20, /// deny write mode
        SH_DENYWR = _SH_DENYWR, /// deny write mode
        _SH_DENYRD = 0x30, /// deny read mode
        SH_DENYRD = _SH_DENYRD, /// deny read mode
        _SH_DENYNO = 0x40, /// deny none mode
        SH_DENYNO = _SH_DENYNO, /// deny none mode
    }
}
