module stdio.vfprintf;

import stdio;
import stdarg;

version (Linux_Musl):

extern (C):

// Import the internal formatter from printf.d
extern int _vsnprintf(void function(char, void*, size_t, size_t), char*, size_t, const char*, va_list);

// Streaming state for vfprintf, kept on the stack (module-level statics
// here would be thread-local and require __tls_get_addr).
struct _vfprintf_state
{
    FILE* stream;
    char[4096] buf;
    size_t base;    // absolute index of buf[0]
    size_t written;
    bool failed;
}

// Stream formatted output through the buffer so arbitrarily long output
// is transmitted in chunks. The formatter's final NUL terminator call
// lands at index == ret and is never flushed, while NUL bytes from %c
// (index < ret) are preserved.
static void _vfprintf_flush(_vfprintf_state* st, size_t count)
{
    // A write callback that returns less than requested (including 0)
    // signals an output error rather than a partial write to retry.
    size_t n = st.stream.write(st.stream,
        cast(const(ubyte*))st.buf.ptr, count);
    if (n != count) {
        st.failed = true;
        return;
    }
    st.written += count;
}

static void _out_char_fprintf(char character, void* buffer, size_t idx, size_t maxlen)
{
    cast(void)maxlen;
    auto st = cast(_vfprintf_state*)buffer;
    size_t pos = idx - st.base;
    if (pos >= st.buf.length) {
        _vfprintf_flush(st, st.buf.length);
        st.base += st.buf.length;
        pos = idx - st.base;
    }
    st.buf[pos] = character;
}

/// vfprintf for Linux_Musl - write formatted output to stream with va_list
/// Note: like the rest of butterlibc, this is not thread-safe; concurrent
/// calls on the same FILE are not serialized (no stream locking yet).
int vfprintf(FILE* stream, const char* format, va_list args)
{
    if (stream is null || stream.write is null || (stream.flags & F_NOWR)) {
        if (stream !is null) {
            auto pflags = cast(uint*)&stream.flags;
            *pflags = *pflags | F_ERR;
        }
        return -1;
    }
    // byte-output establishes byte orientation (C99)
    if (stream.mode == 0)
        stream.mode = -1;
    _vfprintf_state st;
    st.stream = stream;
    st.base = 0;
    st.written = 0;
    st.failed = false;
    const int ret = _vsnprintf(&_out_char_fprintf, cast(char*)&st, cast(size_t)-1, format, args);
    if (ret >= 0 && cast(size_t)ret > st.base)
        _vfprintf_flush(&st, cast(size_t)ret - st.base);
    if (st.failed || ret < 0) {
        auto pflags = cast(uint*)&stream.flags;
        *pflags = *pflags | F_ERR;
        return -1;
    }
    return cast(int)st.written;
}
