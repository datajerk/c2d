/*

c2d, Code to Disk, Version 0.55

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

Bugs:
	*  Yes (input checking)

*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <sys/stat.h>
#include "c2d.h"
#include "holes.h"

#define VERSION "Version 0.55"
#define INFILE argv[argc-2]
#define OUTFILE argv[argc-1]
#define BINARY 0
#define MONITOR 1
#define LOADER "loader"

void usage();
char *getext(char *filename);

int main(int argc, char **argv)
{
	FILE *ifp, *ofp;
	int c, i, j, k, start = 0, loadaddress, inputtype, warm = 0, filesize = 0, unpatch = 0;
	int loaderstart, loader = 0, loadersize = 0, loaderbasesize = 0, textpagesize = 0, bar = 0, row = 19;
	struct stat st;
	char *filetypes[] = { "BINARY", "MONITOR" };
	char *ext, filename[256], load_address[10], *textpage = NULL;

	opterr = 1;
	while ((c = getopt(argc, argv, "r:t:vmh?s:ub")) != -1)
		switch (c) {
		case 't':	// load a splash page while loading binary
			loader = 1;
			textpage = optarg;
			break;
		case 'm':	// boot to monitor
			warm = 1;
			break;
		case 'v':	// version
			fprintf(stderr, "\n%s\n\n", VERSION);
			return 1;
			break;
		case 's':	// start here instead of load address
			warm = 0;
			start = (int) strtol(optarg, (char **) NULL, 16);	// todo: input check
			break;
		case 'r':	// bar row
			row = (int) strtol(optarg, (char **) NULL, 10);	// todo: input check
			break;
		case 'u':
			unpatch = 1;
			break;
		case 'b':
			bar = 1;
			break;
		case 'h':	// help
		case '?':
			usage();
			return 1;
		}

	if (argc - optind < 2) {
		usage();
		return 1;
	}

	fprintf(stderr, "\n");

	inputtype = BINARY;

	k = 0;
	for (j = 0; j < strlen(INFILE); j++) {
		if (INFILE[j] == ',')
			break;
		filename[k++] = INFILE[j];
	}
	filename[k] = '\0';

	k = 0;
	j++;
	for (; j < strlen(INFILE); j++)
		load_address[k++] = INFILE[j];
	load_address[k] = '\0';
	if (k == 0)
		loadaddress = -1;
	else
		loadaddress = (int) strtol(load_address, (char **) NULL, 16);	// todo: input check

	if ((ext = getext(filename)) != NULL)
		if (strcmp(ext, "mon") == 0 || strcmp(ext, "MON") == 0)
			inputtype = MONITOR;

	if ((ifp = fopen(filename, "rb")) == NULL) {
		fprintf(stderr, "Cannot read: %s\n\n", filename);
		return 1;
	}

	fprintf(stderr, "Reading %s, type %s, load address: $", filename, filetypes[inputtype]);

	if (inputtype == BINARY) {
		unsigned char b;

		stat(filename, &st);
		filesize = st.st_size;

		if (loadaddress == -1) {
			fread(&b, 1, 1, ifp);
			loadaddress = b;
			fread(&b, 1, 1, ifp);
			loadaddress |= b << 8;
			fread(&b, 1, 1, ifp);
			filesize = b;
			fread(&b, 1, 1, ifp);
			filesize |= b << 8;
		}
		//check for errors
		fread(&blank.track[1 + loader].sector[0].byte[loadaddress & 0xFF], filesize, 1, ifp);
	}

	// todo: lots of input checking 
	if (inputtype == MONITOR) {
		int byte, naddr;
		char addrs[8], s;
		unsigned char *p = NULL;

		loadaddress = -1;
		filesize = 0;

		while (fscanf(ifp, "%s ", addrs) != EOF) {
			naddr = (int) strtol(addrs, (char **) NULL, 16);
			if (loadaddress == -1) {
				loadaddress = naddr;
				p = &blank.track[1 + loader].sector[0].byte[loadaddress & 0xFF];
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

	fprintf(stderr, "%04X, length: %d\n", loadaddress, filesize);
	fprintf(stderr, "\n");

	if (!start)
		start = loadaddress;
	if (warm)
		start = 0xFF69;

	if (!loader) {
		blank.track[0].sector[1].byte[0xE0] = ceil((filesize + (loadaddress & 0xFF)) / 256.0);
		blank.track[0].sector[1].byte[0xE7] = ((loadaddress + filesize - 1) >> 8) + 1;
		blank.track[0].sector[1].byte[0x15] = ceil((filesize + (loadaddress & 0xFF)) / 4096.0);
		blank.track[0].sector[1].byte[0x1A] = ceil((filesize + (loadaddress & 0xFF)) / 256.0) - 16 * (ceil((filesize + (loadaddress & 0xFF)) / 4096.0) - 1) - 1;

		fprintf(stderr, "Number of sectors:    %d\n", (int) ceil((filesize + (loadaddress & 0xFF)) / 256.0));
		fprintf(stderr, "Memory page range:    $%02X - $%02X\n", loadaddress >> 8, (loadaddress + filesize - 1) >> 8);

		blank.track[0].sector[1].byte[0x3B] = 0x4C;
		blank.track[0].sector[1].byte[0x3C] = start & 0xFF;
		blank.track[0].sector[1].byte[0x3D] = start >> 8;

		fprintf(stderr, "After boot, jump to:  $%04X\n\n", start);

		fprintf(stderr, "Writing %s to T:01/S:00 - T:%02d/S:%02d on %s\n\n", filename, blank.track[0].sector[1].byte[0x15], blank.track[0].sector[1].byte[0x1A], OUTFILE);
	} else {
		if ((ifp = fopen(textpage, "rb")) == NULL) {
			fprintf(stderr, "Cannot read: %s\n\n", textpage);
			return 1;
		}

		stat(textpage, &st);
		textpagesize = st.st_size;

		if (textpagesize != 1024) {
			fprintf(stderr, "textpage %s size %d != 1024\n\n", textpage, textpagesize);
			return 1;
		}

		// check for errors
		fread(&blank.track[1].sector[0].byte[0], textpagesize, 1, ifp);
		fclose(ifp);

		// patch holes
		if(!unpatch) {
			uint64_t *p = (uint64_t *)&blank.track[1].sector[0].byte[0];	// set to start of splash page
			uint64_t *h = (uint64_t *)&holes;								// holes are 64-bits
			int i;

			p -= 1;		// back up virtual hole

			for(i = 0; i < 8; i++) {
				p += 16;	// 3 lines x 40 columns + last hole / 8 (64-bit);
				*p = *h++;	// copy screen hole data
			}
		}

		if(!bar) {
			loaderbasesize = sizeof(loadercode);
			if ((loadersize = sizeof(loadercode)) > 256) {
				fprintf(stderr, "Loader code size %d > 256\n\n", loadersize);
				return 1;
			}

			for (i = 0; i < loadersize; i++)
				blank.track[1].sector[4].byte[i] = loadercode[i];
		}
		else {
			loaderbasesize = sizeof(barcode);
			if ((loadersize = sizeof(barcode)) > 256) {
				fprintf(stderr, "Loader code size %d > 256\n\n", loadersize);
				return 1;
			}

			for (i = 0; i < loadersize; i++)
				blank.track[1].sector[4].byte[i] = barcode[i];
		}

		// loader args
		// lasttrack
		blank.track[1].sector[4].byte[loadersize] = 1 + (int) ceil(filesize / 4096.0);
		// lastsector
		blank.track[1].sector[4].byte[loadersize + 1] = ceil((filesize % 4096) / 256.0) - 1;
		// loadpage
		blank.track[1].sector[4].byte[loadersize + 2] = loadaddress >> 8;
		// program start LSB
		blank.track[1].sector[4].byte[loadersize + 3] = start & 0xFF;
		// program start MSB
		blank.track[1].sector[4].byte[loadersize + 4] = start >> 8;

		//bar code, pre compute status bar table
		if(bar) {
			int num_sectors = (int) ceil((filesize + (loadaddress & 0xFF)) / 256.0);
			int bar_length = 40;
			int i;

			// bar row
			blank.track[1].sector[4].byte[loadersize + 5] = row;

			for(i = 1; i <= bar_length; i++)
				blank.track[1].sector[4].byte[loadersize + 5 + i] = i * num_sectors / bar_length;
		}

		loaderstart = 0x400;

		// temp hack to effect the sound of the drive, i.e. to make consistent
		// longer term put binary payload at end of loader
		// loadersize += (1024 + 5);	// textpage + loader + loader args
		loadersize = 4096;

		blank.track[0].sector[1].byte[0xE0] = ceil((loadersize + (loaderstart & 0xFF)) / 256.0);
		blank.track[0].sector[1].byte[0xE7] = ((loaderstart + loadersize - 1) >> 8) + 1;
		blank.track[0].sector[1].byte[0x15] = ceil((loadersize + (loaderstart & 0xFF)) / 4096.0);
		blank.track[0].sector[1].byte[0x1A] = ceil((loadersize + (loaderstart & 0xFF)) / 256.0) - 16 * (ceil((loadersize + (loaderstart & 0xFF)) / 4096.0) - 1) - 1;

		fprintf(stderr, "Loader number of sectors:    %d\n", (int) ceil((loadersize + (loaderstart & 0xFF)) / 256.0));
		fprintf(stderr, "Loader memory page range:    $%02X - $%02X\n", loaderstart >> 8, (loaderstart + loadersize - 1) >> 8);
		fprintf(stderr, "After loader, jump to:       $%04X\n", start);
		fprintf(stderr, "Binary Number of sectors:    %d\n", (int) ceil((filesize + (loadaddress & 0xFF)) / 256.0));
		fprintf(stderr, "Binary Memory page range:    $%02X - $%02X\n", loadaddress >> 8, (loadaddress + filesize - 1) >> 8);

		loaderstart = 0x800;

		blank.track[0].sector[1].byte[0x3B] = 0x4C;
		blank.track[0].sector[1].byte[0x3C] = loaderstart & 0xFF;
		blank.track[0].sector[1].byte[0x3D] = loaderstart >> 8;

		fprintf(stderr, "After boot, jump to:         $%04X\n", loaderstart);
		fprintf(stderr, "\n");
		fprintf(stderr, "Writing %s to T:02/S:00 - T:%02d/S:%02d on %s\n\n", filename, blank.track[1].sector[4].byte[sizeof(loadercode)], blank.track[1].sector[4].byte[loaderbasesize + 1], OUTFILE);
	}

	if ((ofp = fopen(OUTFILE, "wb")) == NULL) {
		fprintf(stderr, "Cannot write: %s\n\n", OUTFILE);
		return 1;
	}
	// check for errors
	fwrite(&blank, 143360, 1, ofp);

	fclose(ofp);

	return 0;
}

char *getext(char *filename)
{
	char stack[256], *rval;
	int i, sp = 0;

	for (i = strlen(filename) - 1; i >= 0; i--) {
		if (filename[i] == '.')
			break;
		stack[sp++] = filename[i];
	}
	stack[sp] = '\0';

	if (sp == strlen(filename) || sp == 0)
		return (NULL);

	if ((rval = (char *) malloc(sp * sizeof(char))) == NULL);	//do error code

	rval[sp] = '\0';
	for (i = 0; i < sp + i; i++)
		rval[i] = stack[--sp];

	return (rval);
}

void usage()
{
	fprintf(stderr, "%s", usagetext);
}
