### Description

`c2d` is a small utility that will read Apple II binary and monitor text files and output a DOS ordered diskette image that will boot your code quickly.

> Based on work by:
> 
> Weishaar, Tom. *Running without filenames*. Open-Apple Jan. 1985 Vol. 1, No. 0: p. 7 (<http://apple2online.com/web_documents/Open%20Apple%20Vol1No00.pdf>)


### Features

*  Platforms tested:
	*  32-bit/64-bit x86 OS/X.
	*  32-bit x86 Windows/MinGW.


### Download

```
git clone https://github.com/datajerk/c2d.git
```

*or*

Download <https://github.com/datajerk/c2d/archive/master.zip> and extract.


### Build Notes

Unix/Linux:

	make

*or*

OS/X, Linux, Cygwin:

	gcc -Wall -Wno-missing-braces -I. -O3 -o c2d c2d.c -lm
	gcc -Wall -O3 -o bin/text2page text2page.c -lm
	gcc -Wall -O3 -o bin/page2text page2text.c -lm

Windows/MinGW:

	PATH=C:\MinGW\bin;%PATH%
	gcc -Wall -Wno-missing-braces -static -I. -O3 -o c2d c2d.c -lm
	gcc -Wall -O3 --static -o bin/text2page text2page.c -lm
	gcc -Wall -O3 --static -o bin/page2text page2text.c -lm


### c2d Usage/Examples

```
usage:  c2d [-vh?]
        c2d [-m] [-t filename] [-s start address override] input[.mon],[load_address] output.dsk

        -h|? this help
        -m jump to monitor after booting
        -s XXXX jump to XXXX after booting
        -t filename where filename is a 1K $400-$7FF text page splash screen.
           The splash screen will display while the binary is loading.
        -v print version number and exit

Input without a .mon extension is assumed to be a binary with a 4 byte header.
If the header is missing then you must append ,load_address to the binary input
filename, e.g. filename,800.  The load address will be read as hex.

input with a .mon extension expected input format:

        0800: A2 FF 9A 20 8C 02 20 4F
        0808: 03 4C 00 FF 20 9E 02 A9

Examples:

        c2d hello hello.dsk
        c2d hello.mon hello.dsk 
        c2d hello,800 hello.dsk 
        c2d -m test,300 test.dsk
        c2d -s 7300 alpha4,400 alpha4.dsk
        c2d -t gameserverclient.textpage gameserverclient,800 gameserverclient.dsk
```

### text2page Example

Input is expected to be ASCII text.  Only the first 40 characters/line and the first 24 lines are read.  See `gameserverclient.text` example.

```
text2page <gameserverclient.text >gameserverclient.textpage
```

### page2text Example

Input is expected to be an Apple II binary from $400-$7FF.  Exactly 1024 bytes.  See `gameserverclient.textpage` example.

```
page2text <gameserverclient.textpage >gameserverclient.text
```

### Bugs

Yes.  No input checking.  Big Endian untested.


### The Ugly Stuff

c2d, Code to Disk, Version 0.43, Sun Apr 16 02:41:26 UTC 2017

(c) 2012,2017 All Rights Reserved, Egan Ford (egan@sense.net)

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
PARTICULAR PURPOSE.

License: Do what you like, remember to credit all sources when using.

