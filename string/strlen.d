module string.strlen;

extern(C):
size_t strlen(char *s)
{
	const char *a = s;

	for (; *s; s++){}
	return s-a;
}
