#include <stdio.h>

int main()
{
	int i, j, k, linemap[24];
	char screen[24][40];

	// build table
	for (j = 0, i = 0; i < 8; i++, j++) {
		linemap[0 + 3 * j] = j;
		linemap[1 + 3 * j] = j + 8;
		linemap[2 + 3 * j] = j + 16;
	}

	// clear screen
	for (i = 0; i < 24; i++)
		for (j = 0; j < 40; j++)
			screen[linemap[i]][j] = ' ';

	for (i = 0; i < 24; i++) {
		for (j = 0; j < 40; j++)
			screen[linemap[i]][j] = getchar() & 0x7F;
		if ((i + 1) % 3 == 0)
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
