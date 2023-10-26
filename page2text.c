#include <stdio.h>

#define MASK 0x7F

int main(int argc, char **argv)
{
	int i, j, k, line;
	char screen[24][40];

	// clear screen (just in case partial dump)
	for (i = 0; i < 24; i++)
		for (j = 0; j < 40; j++)
			screen[i][j] = ' ';

	for (i = 0; i < 24; i++) {
		line = 8 * (i % 3) + i / 3;
		for (j = 0; j < 40; j++)
			screen[line][j] = getchar() & MASK;
		if (i % 3 == 2)
			for (k = 0; k < 8; k++)
				getchar();
	}

	// dump to stdout
	for (i = 0; i < 24; i++) {
		for (j = 0; j < 40; j++)
			putchar(screen[i][j]);
		printf("\n");
	}

	return 0;
}
