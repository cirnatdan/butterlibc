module string.strchrnul;

import string.strlen;

char *__strchrnul(char *s, int c)
{
	c = cast(ubyte)c;
	if (!c) return cast(char *)s + strlen(s);


	for (; *s && *cast(ubyte *)s != c; s++){}
	return cast(char *)s;
}

alias __strchrnul strchrnul;
