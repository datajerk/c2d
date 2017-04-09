
WIN32GCC = /usr/local/gcc-4.8.0-qt-4.8.4-for-mingw32/win32-gcc/bin/i586-mingw32-gcc

all: bin/c2d bin/text2page

windows: bin/c2d.exe bin/text2page.exe

dist: all windows

c2d.h: c2d.h.0 asm/loader.s makeheader
	./makeheader

bin/c2d: c2d.c c2d.h
	gcc -Wall -Wno-missing-braces -I. -O3 -o bin/c2d c2d.c -lm

bin/c2d.exe: c2d.c c2d.h
	$(WIN32GCC) -Wall -Wno-missing-braces -I. -O3 -o bin/c2d.exe c2d.c

bin/text2page: text2page.c
	gcc -Wall -O3 -o bin/text2page text2page.c -lm

bin/text2page.exe: text2page.c
	$(WIN32GCC) -Wall -O3 -o bin/text2page.exe text2page.c

clean:
	rm -f bin/* *.dsk

test: gameserverclient bin/c2d bin/c2d.exe
	./test.sh
