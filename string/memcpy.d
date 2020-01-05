void *memcpy(void* dest, const void* src, size_t n)
{
	ubyte* d = dest;
	const ubyte* s = src;

	for (; n; n--) *d++ = *s++;
	return dest;
}
