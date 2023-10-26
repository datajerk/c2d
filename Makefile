
WIN32GCC = /usr/local/gcc-4.8.0-qt-4.8.4-for-mingw32/win32-gcc/bin/i586-mingw32-gcc
C2T = c2t

all: bin/c2d bin/text2page bin/page2text

windows: bin/c2d.exe bin/text2page.exe bin/page2text.exe

dist: all windows

cc65-sources-2.13.3.tar.bz2:
	curl -sLO https://github.com/mrdudz/cc65-old/raw/master/cc65-sources-2.13.3.tar.bz2

cc65-2.13.3/bin/cl65: cc65-sources-2.13.3.tar.bz2
	tar zxf cc65-sources-2.13.3.tar.bz2
	(cd cc65-2.13.3; /usr/bin/sed 's!/usr/local!'${PWD}'/cc65-2.13.3!' <make/gcc.mak >Makefile; make -j4 bins || make bins && make install || true)

c2d.h: c2d.h.0 asm/loader.s asm/bar.s makeheader cc65-2.13.3/bin/cl65
	./makeheader

bin/c2d_arm: c2d.c c2d.h
	$(CC) -Wall -Wno-missing-braces -I. -O3 -target arm64-apple-macos11 -o $@ $< -lm

bin/text2page_arm: text2page.c
	$(CC) -Wall -O3 -target arm64-apple-macos11 -o $@ $< -lm

bin/page2text_arm: page2text.c
	$(CC) -Wall -O3 -target arm64-apple-macos11 -o $@ $< -lm

bin/mandelbrotgr_arm: mandelbrotgr.c
	$(CC) -Wall -O3 -target arm64-apple-macos11 -o $@ $< -lm

bin/c2d_x86: c2d.c c2d.h
	$(CC) -Wall -Wno-missing-braces -I. -O3 -target x86_64-apple-macos10.12 -o $@ $< -lm

bin/text2page_x86: text2page.c
	$(CC) -Wall -O3 -target -x86_64-apple-macos10.12 -o $@ $< -lm

bin/page2text_x86: page2text.c
	$(CC) -Wall -O3 -target x86_64-apple-macos10.12 -o $@ $< -lm

bin/mandelbrotgr_x86: mandelbrotgr.c
	$(CC) -Wall -O3 -target x86_64-apple-macos10.12 -o $@ $< -lm

bin/c2d: bin/c2d_x86 bin/c2d_arm
	lipo -create -output $@ $<

bin/text2page: bin/text2page_x86 bin/text2page_arm
	lipo -create -output $@ $<

bin/page2text: bin/page2text_x86 bin/page2text_arm
	lipo -create -output $@ $<

bin/mandelbrotgr: bin/mandelbrotgr_x86 bin/mandelbrotgr_arm
	lipo -create -output $@ $<

bin/c2d.exe: c2d.c c2d.h
	$(WIN32GCC) -Wall -Wno-missing-braces -I. -O3 -o $@ $<

bin/text2page.exe: text2page.c
	$(WIN32GCC) -Wall -O3 -o $@ $<

bin/page2text.exe: page2text.c
	$(WIN32GCC) -Wall -O3 -o $@ $<

clean:
	rm -rf bin/* *.dsk c2d.h c2d.h.1 cc65-sources-2.13.3.tar.bz2 cc65-2.13.3
	(cd asm; make clean)

gameserverclient.text: Makefile
	( \
	figlet -c -w 40 -f slant "Apple ][ Game Server Online!" | \
	perl -p -e 's/^ +\n$$//' | \
	sed '1,6s/^/ /'; \
	echo; \
	text="THE APPLE ][ AE WARESHOLE IS BACK!"; printf "%*s\n" $$((($${#text}+40)/2)) "$$text"; \
	text="CASSETTE PORT FTW! ---- ASCIIEXPRESS.NET"; printf "%*s\n" $$((($${#text}+40)/2)) "$$text"; \
	) | tail -24 >$@

barloader.text: Makefile
	( \
	echo; \
	figlet -c -w 40 -f poison "c2d"; \
	echo; \
	text="C2D (CODE TO DISK) BUILT-IN LOADER"; printf "%*s\n" $$((($${#text}+40)/2)) "$$text"; \
	echo; \
	text="LOADING GAME SERVER CLIENT ..."; printf "%*s\n" $$((($${#text}+40)/2)) "$$text"; \
	echo; \
	text="________________________________________"; printf "%*s\n" $$((($${#text}+40)/2)) "$$text"; \
	text="________________________________________"; printf "%*s\n" $$((($${#text}+40)/2)) "$$text"; \
	echo; \
	echo; \
	text="HTTP://GITHUB.COM/DATAJERK/C2D"; printf "%*s\n" $$((($${#text}+40)/2)) "$$text"; \
	) | tail -24 >$@

barloader.textpage: barloader.text bin/text2page
	bin/text2page <$< >$@

gameserverclientbar.dsk: barloader.textpage gameserverclient bin/c2d Makefile
	bin/c2d -b -t $< gameserverclient,800 $@

bargrloader.textpage: bin/mandelbrotgr
	bin/mandelbrotgr >$@

gameserverclientbargr.dsk: bargrloader.textpage gameserverclient bin/c2d Makefile
	bin/c2d -b -g -r 23 -t $< gameserverclient,800 $@

gameserverclient.dsk: gameserverclient bin/c2d Makefile
	bin/c2d gameserverclient,800 $@

dsk: gameserverclient.dsk gameserverclientbar.dsk gameserverclientbargr.dsk

gameserverclient.mon: gameserverclient
	$(C2T) gameserverclient,800 gameserverclient.mon

fulltest: gameserverclient gameserverclient.mon gameserverclient.text gameserverclient.tiff gameserverclientsplash.tiff test.sh test.scrp dist
	EMU=1 WIN=1 ./test.sh

disttest: gameserverclient gameserverclient.mon gameserverclient.text test.sh dist
	EMU=0 WIN=1 ./test.sh

test: gameserverclient gameserverclient.mon gameserverclient.text test.sh all
	EMU=0 WIN=0 ./test.sh

