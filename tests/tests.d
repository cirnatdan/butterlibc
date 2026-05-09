import prng.rand;
import stdio.printf;

extern(C) void test_varargs() {}

@nogc
extern (C) void main() {
	printf("Running tests\n");

	srand(10);
	int expected = 225495755;
	int random = rand();

	// Print the random number digit by digit
	int original_random = random;
	int lastdigit = 0;
	char digit_char;
	
	if (random == 0) {
		printf("0\n");
	} else {
		do {
			lastdigit = random % 10;
			digit_char = cast(char)(lastdigit + '0');
			printf("%c", digit_char);
			random = random / 10;
		} while (random);
		printf("\n");
	}

	// Test if the generated random number is smaller than expected
	if (original_random < expected) {
		printf("smaller\n");
	}

	// Print the expected value for comparison
	printf("Expected: %d\n", expected);
	printf("Generated: %d\n", original_random);

	return;
}
