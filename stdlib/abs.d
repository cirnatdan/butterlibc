extern (C) int abs(int a)
{
	return a>0 ? a : -a;
}

unittest
{
	//assert(abs(-1) == 1);
 //   assert(abs(1)  == 1);
}