#!/bin/bash

set -e

PATH=bin:$PATH
BIN=gameserverclient
ADDR=800
SUM=898ebb103fdda6fffe62394c1b915d1d

rm -f ${BIN}.dsk
echo
echo "Testing OS/X c2d..."
echo
echo "c2d ${BIN},${ADDR} ${BIN}.dsk"
c2d ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
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

SUM=d70651dcc97e854aad3b4164948fec4a

rm -f ${BIN}.dsk
echo
echo "Testing OS/X c2d textpage..."
echo
echo "text2page <${BIN}.text | page2text | text2page >${BIN}.textpage"
text2page <${BIN}.text | page2text | text2page >${BIN}.textpage
echo "c2d -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk"
c2d -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
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

BIN=gameserverclient
MON=gameserverclient.mon
ADDR=800
SUM=898ebb103fdda6fffe62394c1b915d1d

rm -f ${BIN}.dsk
echo
echo "Testing OS/X c2d..."
echo
echo "c2d ${MON} ${BIN}.dsk"
c2d ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
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
wine bin/c2d.exe ${MON} ${BIN}.dsk 2>&1 | sed 's/^/    /'
CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
if [ "$CHECK" = "$SUM" ]
then
	echo PASSED
else
	echo "FAILED $CHECK != $SUM (expect)"
	exit 1
fi

SUM=d70651dcc97e854aad3b4164948fec4a

rm -f ${BIN}.dsk
echo
echo "Testing OS/X c2d textpage..."
echo
echo "text2page <${BIN}.text >${BIN}.textpage"
text2page <${BIN}.text >${BIN}.textpage
echo "c2d -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk"
c2d -t ${BIN}.textpage ${MON} ${BIN}.dsk 2>&1 | sed 's/^/    /'
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
wine bin/c2d.exe -t ${BIN}.textpage ${MON} ${BIN}.dsk 2>&1 | sed 's/^/    /'
CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
if [ "$CHECK" = "$SUM" ]
then
	echo PASSED
else
	echo "FAILED $CHECK != $SUM (expect)"
	exit 1
fi

echo
