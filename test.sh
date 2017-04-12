#!/bin/bash

set -e

BIN=gameserverclient
ADDR=800
SUM=898ebb103fdda6fffe62394c1b915d1d

rm -f ${BIN}.dsk
echo
echo "Testing OS/X c2d..."
echo
echo "bin/c2d ${BIN},${ADDR} ${BIN}.dsk"
bin/c2d ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
if [ "$CHECK" = "$SUM" ]
then
	echo PASSED
else
	echo "FAILED $CHECK != $SUM (expect)"
	exit 1
fi

rm -f ${BIN}.dsk
echo
echo "Testing Windows c2d..."
echo
PATH=$HOME/wine/bin:$PATH
echo "wine bin/c2d.exe ${BIN},${ADDR} ${BIN}.dsk"
wine bin/c2d.exe ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
if [ "$CHECK" = "$SUM" ]
then
	echo PASSED
else
	echo "FAILED $CHECK != $SUM (expect)"
	exit 1
fi

SUM=57557acfd26f4c1e12ced4cf125bc97f

rm -f ${BIN}.dsk
echo
echo "Testing OS/X c2d textpage..."
echo
echo "bin/text2page <${BIN}.text >${BIN}.textpage"
bin/text2page <${BIN}.text >${BIN}.textpage
echo "bin/c2d -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk"
bin/c2d -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
if [ "$CHECK" = "$SUM" ]
then
	echo PASSED
else
	echo "FAILED $CHECK != $SUM (expect)"
	exit 1
fi

rm -f ${BIN}.dsk
echo
echo "Testing Windows c2d textpage..."
echo
PATH=$HOME/wine/bin:$PATH
echo "wine bin/text2page.exe <${BIN}.text >${BIN}.textpage"
wine bin/text2page.exe <${BIN}.text >${BIN}.textpage
echo "wine bin/c2d.exe -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk"
wine bin/c2d.exe -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
if [ "$CHECK" = "$SUM" ]
then
	echo PASSED
else
	echo "FAILED $CHECK != $SUM (expect)"
	exit 1
fi

echo
