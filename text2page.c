#include <stdio.h>

unsigned char holes[] = {
	0x37, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00,
	0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00,
	0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00,
	0xff, 0xff, 0x00, 0x17, 0xff, 0xff, 0x00, 0x00,
	0xff, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00,
	0xff, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00,
	0xff, 0xff, 0x00, 0xd0, 0xff, 0xff, 0x00, 0x00,
	0xc6, 0xff, 0x00, 0x07, 0xff, 0xff, 0x00, 0x00
};

int main()
{
	char c, highbit = 0x80;
	int i, j, k, column = 0, line = 0, linemap[24];
	unsigned char screen[24][40];

	// build table
	for (i = 0; i < 8; i++) {
		linemap[0 + i] = 0 + 3 * i;
		linemap[8 + i] = 1 + 3 * i;
		linemap[16 + i] = 2 + 3 * i;
	}

	// clear screen
	for (i = 0; i < 24; i++)
		for (j = 0; j < 40; j++)
			screen[linemap[i]][j] = ' ' | highbit;

	while ((c = getchar()) != EOF) {
		if (c == '\r')			// windows trash
			continue;
		if (c == '\n') {		// end of line
			column = 0;
			line++;
			continue;
		}
		if (column > 39)		// user didn't read the docs
			continue;
		if (line > 23)			// ditto
			break;

		screen[linemap[line]][column++] = c | highbit;
	}

	// dump to stdout
	for (i = 0; i < 24; i++) {
		for (j = 0; j < 40; j++)
			putchar(screen[i][j]);
		if ((i + 1) % 3 == 0)
			for (k = 0; k < 8; k++)
				putchar(holes[(i / 3) * 8 + k]);
	}

	return 0;
}
