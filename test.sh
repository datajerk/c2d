#!/bin/bash

set -e

BIN=gameserverclient
ADDR=800
SUM=898ebb103fdda6fffe62394c1b915d1d

rm -f ${BIN}.dsk
echo
echo "Testing OS/X c2d..."
bin/c2d ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
if [ "$CHECK" = "$SUM" ]
then
	echo PASSED
else
	echo FAILED
	exit 1
fi

rm -f ${BIN}.dsk
echo
echo "Testing Windows c2d..."
PATH=$HOME/wine/bin:$PATH
wine bin/c2d.exe ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
if [ "$CHECK" = "$SUM" ]
then
	echo PASSED
else
	echo FAILED
	exit 1
fi

SUM=d12ba3c2db1cd3de352f182e0530940d

rm -f ${BIN}.dsk
echo
echo "Testing OS/X c2d textpage..."
bin/text2page <${BIN}.text >${BIN}.textpage
bin/c2d -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
if [ "$CHECK" = "$SUM" ]
then
	echo PASSED
else
	echo FAILED
	exit 1
fi

rm -f ${BIN}.dsk
echo
echo "Testing Windows c2d textpage..."
PATH=$HOME/wine/bin:$PATH
wine bin/text2page.exe <${BIN}.text >${BIN}.textpage
wine bin/c2d.exe -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
if [ "$CHECK" = "$SUM" ]
then
	echo PASSED
else
	echo FAILED
	exit 1
fi
