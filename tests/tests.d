import prng.rand;
import tests.debug_print;

import stdio.printf;

@nogc
extern (C) int main() {
	printf_("successfully printed\n");

	debug_print.debug_print(cast(char*)"Running tests\n", cast(short*)15);

	srand(10);
	int expected = 225495755;
	int random = rand();

	int lastdigit = 0;
	do {
		lastdigit = random % 10;
		lastdigit = lastdigit + 48;

		debug_print.debug_print(cast(char*)&lastdigit, cast(short*)1);
		random = random / 10;
	} while (random);
	debug_print.debug_print(cast(char*)"\n", cast(short*)4);



	if (random < 10) {
		debug_print.debug_print(cast(char*)"smaller\n", cast(short*)13);
	}

	return 0;
}