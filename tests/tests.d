import prng.rand;

import stdio.printf;

extern(C) void test_varargs() {}

@nogc
extern (C) void main() {
	printf("Running tests\n");

	srand(10);
	int expected = 225495755;
	int random = rand();

	int lastdigit = 0;
	do {
		lastdigit = random % 10;
		lastdigit = lastdigit + 48;

		printf(cast(char*)&lastdigit);
		random = random / 10;
	} while (random);
	printf(cast(char*)"\n");



	if (random < 10) {
		printf(cast(char*)"smaller\n");
	}

	return;
}
