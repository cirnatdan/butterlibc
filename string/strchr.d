module string.strchr;

import string.strchrnul;

extern(C):
char* strchr(char *s, int c)
{
	char* r = __strchrnul(s, c);
	return *cast(ubyte*)r == cast(ubyte)c ? r : cast(char*)0;
}
