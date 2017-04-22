#include <stdio.h>
#include "holes.h"

#define NORMAL 0x80
#define BLINK 0x40

int main()
{
	char c;
	int i, j, k, line = 0;
	unsigned char screen[24][40];

	// clear screen (just in case < 40x24)
	for (i = 0; i < 24; i++)
		for (j = 0; j < 40; j++)
			screen[i][j] = ' ' | NORMAL;

	i = j = 0;
	while ((c = getchar()) != EOF) {
		if (c == '\r')			// windows trash
			continue;
		if (c == '\n') {		// end of line
			j = 0;
			i++;
			line = 3 * (i % 8) + i / 8;
			continue;
		}
		if (j > 39)				// user didn't read the docs
			continue;
		if (i > 23)				// ditto
			break;

		screen[line][j++] = c | NORMAL;
	}

	// dump to stdout
	for (i = 0; i < 24; i++) {
		for (j = 0; j < 40; j++)
			putchar(screen[i][j]);
		if (i % 3 == 2)
			for (k = 0; k < 8; k++)
				putchar(holes[(i / 3) * 8 + k]);
	}

	return 0;
}
