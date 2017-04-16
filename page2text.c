#include <stdio.h>

int main()
{
	unsigned char c;
	int i, j, k, count=0, linemap[24];
	unsigned char screen[24][40];

	// build table
	for(j=0,i=0;i<8;i++) {
		linemap[0+3*j]=j;
		linemap[1+3*j]=j+8;
		linemap[2+3*j]=j+16;
		j++;
	}

	// clear screen
	for(i=0;i<24;i++)
		for(j=0;j<40;j++) 
			screen[linemap[i]][j] = ' ';

	for(i=0;i<24;i++) {
		for(j=0;j<40;j++) {
			c = getchar();
			count++;
			screen[linemap[i]][j] = c & 0x7F;
		}
		if((i + 1) % 3 == 0)
			for(k=0;k<8;k++) {
				c = getchar();
				count++;
			}
	}

	if(count != 1024) {
		fprintf(stderr,"input size < 1024\n\n");
		return 1;
	}

	// dump to stdout
	for(i=0;i<24;i++) {
		for(j=0;j<40;j++)
			putchar(screen[i][j]);
		printf("\n");
	}

	return 0;
}
