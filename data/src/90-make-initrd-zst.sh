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

#	 if [ "`id -u`" -ne 0 ]; then
#        echo "sudo do as root!"
#        exit 1
#    fi

KernelVersion=$(basename ${SYSTEM}/lib/modules/*)

MakeVersion=00000$(cat linux-$KernelVersion/.version)

cat > a.py <<EOF

a="$MakeVersion"
print(a[-4:])

EOF

MAKEVERSION=$(python3 a.py)
rm a.py

IMAGENAME=initrd.img-$KernelVersion-$MAKEVERSION
echo $IMAGENAME

      echo "creating $IMAGENAME.zst from $SYSTEM"
#	  (cd "$SYSTEM"; sudo find . | sudo cpio -o -H newc | sudo lzma -9 > ../"$IMAGENAME.lzma")
	  (cd "$SYSTEM"; sudo find . | sudo cpio -o -H newc | sudo zstd  > ../"$IMAGENAME.zst")
      sudo cp "$IMAGENAME.zst" /boot/my-initrd
      echo
      echo "$?"
      echo

      echo
      echo "make initrd(zst), done!"
      echo

      exit 0

