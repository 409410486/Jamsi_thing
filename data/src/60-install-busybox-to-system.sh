#!/bin/bash

###################################################################
#Script Name	:
#Description	:
#Args          	:
#Author       	:
#Email         	:
###################################################################

#	cd ~/rootfs/src
#	tar jxf busybox-1.32.1.tar.bz2
#	cp busybox-1.32.1-config busybox-1.32.1/.config
#	mv busybox-1.32.1/ ../
#	cd ../busybox-1.32.1

BUSYBOX=$(basename `pwd`)

cat >a.py <<EOF

a="$BUSYBOX"
print(a[0:7])

EOF

busybox=$(python3 a.py)
rm a.py

    if [ ! $busybox = "busybox" ]; then
      echo "must in busybox directory"
      exit 1
     fi

	make menuconfig

	make -j 8

    if [ ! "$?" = 0 ]; then
        echo
        echo "Make Busybox error!"
        echo
        exit 1
    fi

    sudo make install

    if [ ! "$?" = 0 ]; then
        echo
        echo "Make install error!"
        echo
        exit 1
    fi

    echo "Copy to system ..."
	sudo cp -a tiny/* ../system

    echo
    echo "$?"
    echo

    echo
    echo "Make Busybox Done!"
    echo

    if [ -f .version ]; then
        v=$(cat .version)
        v=$(echo $v + 1 | bc)
        echo $v > .version
    else
        echo 1 > .version
    fi


    MakeVersion=00000$(cat .version)

cat > a.py <<EOF

a="$MakeVersion"
print(a[-4:])

EOF

MAKEVERSION=$(python3 a.py)
rm a.py

cp .config $BUSYBOX-config-$MAKEVERSION

    exit 0

