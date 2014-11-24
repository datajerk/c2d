### Description

`c2d` is a small utility that will read Apple II binary and monitor text files and output a DOS ordered dsk image that will boot your code quickly.

> Based on work by:

> Weishaar, Tom. "Running without filenames". Open-Apple Jan. 1985 Vol. 1, No. 0: p. 7 (<http://apple2online.com/web_documents/Open%20Apple%20Vol1No00.pdf>)


### Features

*  Apple II+, IIe support.
*  Big and little-endian machine support.
	*  Little-endian tested.
*  Platforms tested:
	*  32-bit/64-bit x86 OS/X.
	*  32-bit x86 Windows/MinGW.


### Distribution Files

| Filename   | Description    |
|------------|----------------|
| c2d        | OS/X Binary    |
| c2d.c      | Source File    |
| c2d.exe    | Windows Binary |
| c2d.h      | Source File    |
| README.md  | This File      |


### Download

```
git clone https://github.com/datajerk/c2d.git
```

*or*

Download <https://github.com/datajerk/c2d/archive/master.zip> and extract.


### Build Notes

OS/X:

	gcc -Wall -O -o c2d c2d.c

Linux:

	gcc -Wall -O -o c2d c2d.c -lm

Windows/Cygwin:

	gcc -Wall -O -o c2d c2d.c

Windows/MinGW:

	PATH=C:\MinGW\bin;%PATH%
	gcc -Wall -O -static -o c2d c2d.c


### Usage/Examples
```
usage:  c2d [-vh?]
        c2d [-m]   input[.mon],[load_address] output.dsk

        -h|? this help
        -m jump to monitor after booting
        -v print version number and exit

input without a .mon extension is assumed to be a binary with a 4 byte header.
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
```


### The Ugly Stuff

c2d, Code to Disk, Version 0.1, Fri Feb 24 22:04:42 GMT 2012

(c) 2012 All Rights Reserved, Egan Ford (egan@sense.net, datajerk@gmail.com)

> THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
PARTICULAR PURPOSE.

License:

*  Do what you like, remember to credit all sources when using.

