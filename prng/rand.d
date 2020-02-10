__gshared static ulong seed;

@nogc
extern(C) void srand(uint s)
{
	seed = s-1;
}

@nogc
extern(C) int rand()
{
	seed = 6364136223846793005UL*seed + 1;
	return seed>>33;
}

unittest
{
	srand(10);
	
	int random = rand();

	int expected = 225495755;
	//assert(expected == random);
}