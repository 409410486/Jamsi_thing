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

echo "make modules..."

SYSTEM=~/rootfs/system/lib

echo $SYSTEM

time make -j 8 modules

	if [ ! "$?" = 0 ]; then
        echo
        echo "Make modules error!"
        echo
        exit 1
    fi

sudo rm -fr ./modules
sudo make -j 8 INSTALL_MOD_PATH=./modules modules_install
sudo find modules/ -name build -exec rm {} \;
sudo find modules/ -name source -exec rm {} \;
#du -d 1 ./modules

echo "remove old modules... "
sudo rm -fr $SYSTEM/modules

echo
echo "copy modules to $SYSTEM"
echo
sudo cp -a ./modules/lib/modules $SYSTEM

echo
echo "$?"
echo
echo "Make modules Done!"

exit 0

