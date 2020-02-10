version (OSX)
    version = Darwin;
else version (iOS)
    version = Darwin;
else version (TVOS)
    version = Darwin;
else version (WatchOS)
    version = Darwin;

extern (C):
@system:
@nogc:

//version (Darwin):
@nogc @system
extern(C) static struct _RuneLocale {
	char[8]		__magic;
	char[32]	__encoding;
}

extern(C) __gshared _RuneLocale _DefaultRuneLocale;
