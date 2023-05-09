#!/bin/bash

set -e

PATH=bin:$PATH
BIN=gameserverclient
ADDR=800
SUM=3226e0aa8f35ee23a9de9b8f05abf688

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
	echo "FAILED $CHECK != $SUM (expected)"
	exit 1
fi

if ((EMU == 1))
then
	echo
	echo -n "Emulator Test..."
	if ! OUTPUT=$(osascript test.scrp gameserverclient.dsk gameserverclient.tiff gameserverclient.tiff 15 15)
	then
		echo FAILED
		exit 1
	fi
	if echo $OUTPUT | grep ERROR >/dev/null 2>&1
	then
		echo FAILED
		echo $OUTPUT
		echo
		exit 1
	fi
	echo PASSED
fi

if ((WIN == 1))
then
	rm -f ${BIN}.dsk
	echo
	echo "Testing Windows c2d..."
	echo
	echo "./dwine bin/c2d.exe ${BIN},${ADDR} ${BIN}.dsk"
	./dwine bin/c2d.exe ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
	CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
	if [ "$CHECK" = "$SUM" ]
	then
		echo PASSED
	else
		echo "FAILED $CHECK != $SUM (expected)"
		exit 1
	fi
fi

SUM=56a52e40a2351ff39669efa3fbdd0f19

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
	echo "FAILED $CHECK != $SUM (expected)"
	exit 1
fi

if ((EMU == 1))
then
	echo
	echo -n "Emulator Test..."
	if ! OUTPUT=$(osascript test.scrp gameserverclient.dsk gameserverclientsplash.tiff gameserverclient.tiff 15 15)
	then
		echo FAILED
		exit 1
	fi
	if echo $OUTPUT | grep ERROR >/dev/null 2>&1
	then
		echo FAILED
		echo $OUTPUT
		echo
		exit 1
	fi
	echo PASSED
fi

if ((WIN == 1))
then
	rm -f ${BIN}.dsk
	echo
	echo "Testing Windows c2d textpage..."
	echo
	echo "./dwine bin/text2page.exe <${BIN}.text >${BIN}.textpage"
	./dwine bin/text2page.exe '<'${BIN}.text '>'${BIN}.textpage
	echo "./dwine bin/c2d.exe -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk"
	./dwine bin/c2d.exe -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk 2>&1 | sed 's/^/    /'
	CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
	if [ "$CHECK" = "$SUM" ]
	then
		echo PASSED
	else
		echo "FAILED $CHECK != $SUM (expected)"
		exit 1
	fi
fi

BIN=gameserverclient
MON=gameserverclient.mon
ADDR=800
SUM=3226e0aa8f35ee23a9de9b8f05abf688

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
	echo "FAILED $CHECK != $SUM (expected)"
	exit 1
fi

if ((WIN == 1))
then
rm -f ${BIN}.dsk
	echo
	echo "Testing Windows c2d..."
	echo
	echo "./dwine bin/c2d.exe ${BIN},${ADDR} ${BIN}.dsk"
	./dwine bin/c2d.exe ${MON} ${BIN}.dsk 2>&1 | sed 's/^/    /'
	CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
	if [ "$CHECK" = "$SUM" ]
	then
		echo PASSED
	else
		echo "FAILED $CHECK != $SUM (expected)"
		exit 1
	fi
fi

SUM=56a52e40a2351ff39669efa3fbdd0f19

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
	echo "FAILED $CHECK != $SUM (expected)"
	exit 1
fi

if ((WIN == 1))
then
	rm -f ${BIN}.dsk
	echo
	echo "Testing Windows c2d textpage..."
	echo
	echo "./dwine bin/text2page.exe <${BIN}.text >${BIN}.textpage"
	./dwine bin/text2page.exe '<'${BIN}.text '>'${BIN}.textpage
	echo "./dwine bin/c2d.exe -t ${BIN}.textpage ${BIN},${ADDR} ${BIN}.dsk"
	./dwine bin/c2d.exe -t ${BIN}.textpage ${MON} ${BIN}.dsk 2>&1 | sed 's/^/    /'
	CHECK=$(md5sum ${BIN}.dsk | awk '{print $1}')
	if [ "$CHECK" = "$SUM" ]
	then
		echo PASSED
	else
		echo "FAILED $CHECK != $SUM (expected)"
		exit 1
	fi
fi

echo
