extern(C) void *memcpy(void* dest, const void* src, size_t n)
{
	ubyte* d = cast(ubyte*)dest;
	ubyte* s = cast(ubyte*)src;

	for (; n; n--) *d++ = *s++;
	return dest;
}
