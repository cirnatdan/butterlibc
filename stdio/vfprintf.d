import stdio;
import stdarg;

extern(C):

union arg
{
	ulong i;
	real f;
	void *p;
};

//static void out(FILE *f, const char *s, size_t l)
//{
//	if (!(f.flags & F_ERR)) __fwritex(cast(void *) s, l, f);
//}

int printf_core(FILE *f, const char* fmt, va_list* ap, arg *nl_arg, int* nl_type)
{
	//TODO
	return 0;
}

int vfprintf(FILE* f, const char* fmt, ...)
{
	//TODO	
	return 0;
}