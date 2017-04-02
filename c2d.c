/*

c2d, Code to Disk, Version 0.31, Sun Apr  2 16:33:28 UTC 2017

(c) 2012,2017 All Rights Reserved, Egan Ford (egan@sense.net)

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
PARTICULAR PURPOSE.

Based on work by:
    * Weishaar, Tom. "Running without filenames". Open-Apple Jan. 1985 Vol. 1, No. 0: p. 7
      (http://apple2online.com/web_documents/Open%20Apple%20Vol1No00.pdf)

License:
	*  Do what you like, remember to credit all sources when using.

Description:
	This small utility will read Apple II binary and monitor text files and
    output a DOS ordered dsk image that will boot your code quickly.

Features:
	*  Apple II+, IIe support.
	*  Big and little-endian machine support.
		o  Little-endian tested.
	*  Platforms tested:
		o  32-bit/64-bit x86 OS/X.
		o  32-bit x86 Windows/MinGW.

Compile:
	OS/X:
		gcc -Wall -O -o c2d c2d.c
	Linux:
		gcc -Wall -O -o c2d c2d.c -lm
	Windows/Cygwin:
		gcc -Wall -O -o c2d c2d.c
	Windows/MinGW:
		PATH=C:\MinGW\bin;%PATH%
		gcc -Wall -O -static -o c2d c2d.c

Bugs:
	*  Probably

*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <sys/stat.h>
#include "c2d.h"

#define VERSION "Version 0.31"
#define INFILE argv[argc-2]
#define OUTFILE argv[argc-1]
#define BINARY 0
#define MONITOR 1

void usage();
char *getext(char *filename);

int main(int argc, char **argv)
{
	FILE *ifp, *ofp;
	int c, j, k, start, start_override = 0, inputtype, warm = 0, filesize = 0;
	struct stat st;
	char *filetypes[] = {"BINARY","MONITOR"};
	char *ext, filename[256], load_address[10];

	opterr = 1;
	while((c = getopt(argc, argv, "vmh?s:")) != -1)
		switch(c) {
			case 'm':
				warm = 1;
				break;
			case 'v':		// version
				fprintf(stderr,"\n%s\n\n",VERSION);
				return 1;
				break;
			case 's':       // override rate for -1/-2 only
				warm = 0;
				start_override = (int)strtol(optarg, (char **)NULL, 16); // todo: input check
				break;
			case 'h':		// help
			case '?':
				usage();
				return 1;
		}

	if(argc - optind < 2) {
		usage();
		return 1;
	}

	fprintf(stderr,"\n");

	inputtype=BINARY;

	k=0;
	for(j=0;j<strlen(INFILE);j++) {
		if(INFILE[j] == ',')
			break;
		filename[k++]=INFILE[j];
	}
	filename[k] = '\0';

	k=0;j++;
	for(;j<strlen(INFILE);j++)
		load_address[k++]=INFILE[j];
	load_address[k] = '\0';
	if(k == 0)
		start = -1;
	else
		start = (int)strtol(load_address, (char **)NULL, 16); // todo: input check

	if((ext = getext(filename)) != NULL)
		if(strcmp(ext,"mon") == 0 || strcmp(ext,"MON") == 0)
			inputtype = MONITOR;

	if ((ifp = fopen(filename, "rb")) == NULL) {
		fprintf(stderr,"Cannot read: %s\n\n",filename);
		return 1;
	}

	fprintf(stderr,"Reading %s, type %s, load address: $",filename,filetypes[inputtype]);

	if(inputtype == BINARY) {
		unsigned char b;

		stat(filename,&st);
		filesize = st.st_size;

		if(start == - 1) {
			fread(&b, 1, 1, ifp);
			start = b;
			fread(&b, 1, 1, ifp);
			start |= b << 8;
			fread(&b, 1, 1, ifp);
			filesize = b;
			fread(&b, 1, 1, ifp);
			filesize |= b << 8;
		}

		//check for errors
		fread(&blank.track[1].sector[0].byte[start & 0xFF], filesize, 1, ifp);
	}

	// todo: lots of input checking 
	if(inputtype == MONITOR) {
		int byte, naddr;
		char addrs[8], s;
		unsigned char *p = NULL;

		start = -1;
		filesize = 0;

		while(fscanf(ifp,"%s ",addrs) != EOF) {
			naddr = (int)strtol(addrs, (char **)NULL, 16);
			if(start == -1) {
				start = naddr;
				p = &blank.track[1].sector[0].byte[start & 0xFF];
			}
	
			while (fscanf(ifp, "%x%c", &byte, &s) != EOF) {
				*p++ = byte;
				filesize++;
				if (s == '\n' || s == '\r')
					break;
			}
		}

	}

	fclose(ifp);

	fprintf(stderr,"%04X, length: %d\n",start,filesize);
	fprintf(stderr,"\n");

	blank.track[0].sector[1].byte[0xE0] = ceil((filesize + (start & 0xFF)) / 256.0);
	blank.track[0].sector[1].byte[0xE7] = ((start + filesize - 1) >> 8) + 1;
	blank.track[0].sector[1].byte[0x15] = ceil((filesize + (start & 0xFF))/ 4096.0);
	blank.track[0].sector[1].byte[0x1A] = ceil((filesize + (start & 0xFF))/ 256.0) - 16*(ceil((filesize + (start & 0xFF)) / 4096.0) - 1) - 1;

	fprintf(stderr,"Number of sectors:    %d\n",(int)ceil((filesize + (start & 0xFF)) / 256.0));
	fprintf(stderr,"Memory page range:    $%02X - $%02X\n",start >> 8,(start + filesize - 1) >> 8);

	if(warm)
		start = 0xFF69;

	if(start_override)
		start = start_override;

	blank.track[0].sector[1].byte[0x3B] = 0x4C;
	blank.track[0].sector[1].byte[0x3C] = start & 0xFF;
	blank.track[0].sector[1].byte[0x3D] = start >> 8;

	fprintf(stderr,"After boot, jump to:  $%04X\n\n",start);

	if ((ofp = fopen(OUTFILE, "wb")) == NULL) {
		fprintf(stderr,"Cannot write: %s\n\n",OUTFILE);
		return 1;
	}

	fprintf(stderr,"Writing %s to T:01/S:00 - T:%02d/S:%02d on %s\n\n",filename,blank.track[0].sector[1].byte[0x15],blank.track[0].sector[1].byte[0x1A],OUTFILE);

	// check for errors
	fwrite(&blank, 143360, 1, ofp);

	return 0;
}

char *getext(char *filename)
{
	char stack[256], *rval;
	int i, sp = 0;

	for(i=strlen(filename)-1;i>=0;i--) {
		if(filename[i] == '.')
			break;
		stack[sp++] = filename[i];
	}
	stack[sp] = '\0';

	if(sp == strlen(filename) || sp == 0)
		return(NULL);

	if((rval = (char *)malloc(sp * sizeof(char))) == NULL)
		; //do error code

	rval[sp] = '\0';
	for(i=0;i<sp+i;i++)
		rval[i] = stack[--sp];

	return(rval);
}

void usage()
{
	fprintf(stderr,"%s",usagetext);
}

