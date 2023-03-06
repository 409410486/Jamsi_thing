#!/bin/sh
if [ $# -ne 1 ]
    then
      echo "usage:$0  filename.txz"
      exit 1
fi

f=`basename $1 .txz`
mkdir -p /tmp/loop/$f
mount $1 /tmp/loop/$f -t squashfs -o loop,ro
cp -as /tmp/loop/"$f"/* /

