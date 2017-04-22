
WIN32GCC = /usr/local/gcc-4.8.0-qt-4.8.4-for-mingw32/win32-gcc/bin/i586-mingw32-gcc

all: bin/c2d bin/text2page bin/page2text

windows: bin/c2d.exe bin/text2page.exe bin/page2text.exe

dist: all windows

c2d.h: c2d.h.0 asm/loader.s makeheader
	./makeheader

bin/c2d: c2d.c c2d.h holes.h
	gcc -Wall -Wno-missing-braces -I. -O3 -o $@ $< -lm

bin/c2d.exe: c2d.c c2d.h holes.h
	$(WIN32GCC) -Wall -Wno-missing-braces -I. -O3 -o $@ $<

bin/text2page: text2page.c holes.h
	gcc -Wall -O3 -o $@ $< -lm

bin/text2page.exe: text2page.c holes.h
	$(WIN32GCC) -Wall -O3 -o $@ $<

bin/page2text: page2text.c
	gcc -Wall -O3 -o $@ $< -lm

bin/page2text.exe: page2text.c
	$(WIN32GCC) -Wall -O3 -o $@ $<

clean:
	rm -f bin/* *.dsk c2d.h c2d.h.1
	(cd asm; make clean)

gameserverclient.text: Makefile
	figlet -c -w 40 -f slant "Game Server Online Client" >$@

emutest: gameserverclient gameserverclient.mon gameserverclient.text dist
	EMU=1 WIN=1 ./test.sh

fulltest: gameserverclient gameserverclient.mon gameserverclient.text dist
	EMU=0 WIN=1 ./test.sh

test: gameserverclient gameserverclient.mon gameserverclient.text all
	EMU=0 WIN=0 ./test.sh

