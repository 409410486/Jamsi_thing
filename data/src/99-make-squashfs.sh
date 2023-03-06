#!/bin/sh

if [ $# -ne 1 ]; then
	echo "need dir."
	exit 1
fi

d=$(basename $1)

sudo rm -f $d.txz

if [ -d $d ]; then
#	sudo mksquashfs $d/ $d.tcz -b 256K -comp zstd -all-root
	sudo mksquashfs $d/ $d.txz -b 256K -comp xz -all-root
else
	echo "directory req."
fi

