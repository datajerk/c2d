
WIN32GCC = /usr/local/gcc-4.8.0-qt-4.8.4-for-mingw32/win32-gcc/bin/i586-mingw32-gcc

all: bin/c2d

windows: bin/c2d.exe

dist: all windows

bin/c2d: c2d.c c2d.h
	gcc -Wall -Wno-missing-braces -I. -O3 -o bin/c2d c2d.c -lm

bin/c2d.exe: c2d.c c2d.h
	$(WIN32GCC) -Wall -Wno-missing-braces -I. -O3 -o bin/c2d.exe c2d.c

clean:
	rm -f bin/* *.dsk

test: gameserverclient bin/c2d bin/c2d.exe
	./test.sh

