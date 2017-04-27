#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <strings.h>
#include "holes.h"

#define MAX 15
#define NORMAL 0x80

// unsigned char colors[16] = { 0xF, 0xE, 0xD, 0xC, 0xB, 0xA, 0x9, 0x8, 0x7, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1, 0x0 };

// chanage order and number of colors for different output
// default palette
// unsigned char colors[15] = { 0xE, 0xD, 0xC, 0xB, 0xA, 0x9, 0x8, 0x7, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1, 0x0 };
// redish
// unsigned char colors[15] = { 0xB, 0x3, 0x1, 0x9, 0xD, 0xE, 0xB, 0x4, 0x7, 0x6, 0x2, 0xA, 0x5, 0x8, 0x0 };
// blueish
unsigned char colors[15] = { 0x2, 0x6, 0x7, 0xE, 0xC, 0x4, 0xD, 0x9, 0xB, 0x3, 0x1, 0xA, 0x5, 0x8, 0x0 };

const char text[4][41] = {
	"EXAMPLE GR SPLASH SCREEN",
	"LOADING GAME SERVER CLIENT ...",
	"________________________________________",
	"________________________________________",
};

int main(int argc, char **argv)
{
	int c, r, i, j, k, line = 0;
	double xd, yd, x0, y0, x, y, xt;
	unsigned char screen[24][40];

	// clear screen to zeros
	for (i = 0; i < 24; i++)
		for (j = 0; j < 40; j++)
			screen[i][j] = 0x00;

	c = 40;
	r = 40;
	xd = (1.0 - -2.5) / (double) c;	// size of x pixel
	yd = (1.0 - -1.0) / (double) r;	// size of y pixel

	// 39 rows, set i = 1
	for (i = 1; i < r; i++) {
		// gr text page translation
		// 40 row
		// line = 3 * ((i / 2) % 8) + i / 16;
		// 39 row
		line = 3 * (((i - 1) / 2) % 8) + (i - 1) / 16;
		y0 = 1 - i * yd;
		for (j = 0; j < c; j++) {
			x0 = -2.5 + j * xd;
			k = x = y = 0;
			while (x * x + y * y <= 4 && k < MAX) {
				xt = x * x - y * y + x0;
				y = 2 * x * y + y0;
				x = xt;
				k++;
			}

			// 39 row
			screen[line][j] |= (colors[(k - 1) / (MAX / sizeof(colors))] << 4 * (i % 2 == 0));

			// 40 row
			//screen[line][j] |= (colors[(k - 1) / (MAX / sizeof(colors))] << 4 * (i % 2));
		}
	}

	// clear text lines with spaces
	for (i = 20; i < 24; i++) {
		line = 3 * (i % 8) + i / 8;
		for (j = 0; j < 40; j++)
			screen[line][j] = ' ' | NORMAL;
	}

	for (i = 0; i < 4; i++) {
		line = 3 * ((i + 20) % 8) + (i + 20) / 8;
		for (j = 0; j < 20 - strlen(text[i]) / 2; j++)
			screen[line][j] = ' ' | NORMAL;	// text rows
		for (k = 0; k < strlen(text[i]); k++)
			screen[line][j++] = text[i][k] | NORMAL;
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
