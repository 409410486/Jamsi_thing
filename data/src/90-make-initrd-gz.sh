#!/bin/sh

    if [ $# -eq 1 ]; then
        SYSTEM=$1

        if [ ! -d "$1" ]; then
            echo "First argument must be a directory"
            exit 1
        fi
    else
        SYSTEM=./system
    fi

KernelVersion=$(basename $SYSTEM/lib/modules/*)
echo $KernelVersion

MakeVersion=00000$(cat linux-$KernelVersion/.version)

cat > a.py <<EOF

a="$MakeVersion"
print(a[-4:])

EOF

MAKEVERSION=$(python3 a.py)
rm a.py

IMAGENAME=initrd.img-$KernelVersion-$MAKEVERSION
echo $IMAGENAME

      echo "creating $IMAGENAME from $SYSTEM"
	  (cd "$SYSTEM"; sudo find . | sudo cpio -o -H newc | sudo gzip -9 > ../"$IMAGENAME.gz")
      echo "copy $IMAGENAME.gz to /boot/my-initrd"
      sudo cp "$IMAGENAME.gz" /boot/my-initrd

	echo
	echo "$?"
	echo

    echo
    echo "make my-initrd(gz) done!"
    echo

	exit 0

