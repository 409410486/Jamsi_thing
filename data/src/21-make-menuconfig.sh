#!/bin/bash

LINUX=$(basename $PWD)
echo $LINUX

cat >a.py <<EOF

a="$LINUX"
print(a[0:5])

EOF

linux=$(python3 a.py)
rm a.py

    if [ ! $linux = "linux" ]; then
      echo "must in linux directory"
      exit 1
     fi

make menuconfig
	
    if [ ! "$?" = 0 ]; then
        echo
        echo "Make menuconfig error!"
        echo
        exit 1
    fi

    echo
    echo "Done!"
    echo

    exit 0

