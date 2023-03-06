#!/bin/bash

LINUX=$(basename `pwd`)

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

time make -j 8 bzImage modules

	if [ ! "$?" = 0 ]; then
        echo
        echo "Make kernel error!"
        echo
        exit 1
    fi

MakeVersion=00000$(cat .version)

cat > a.py <<EOF

a="$MakeVersion"
print(a[-4:])

EOF

MAKEVERSION=$(python3 a.py)
rm a.py

cat > a.py <<EOF

a="$LINUX"
print(a[6:])

EOF
KernelVersion=$(python3 a.py)
rm a.py
echo $KernelVersion

cp arch/x86/boot/bzImage vmlinuz-$KernelVersion-$MAKEVERSION

echo
echo 'copy bzImage to /boot/my-kernel!'
echo
sudo cp arch/x86/boot/bzImage /boot/my-kernel

#save configure file
cp .config linux-$KernelVersion-config-$MAKEVERSION

echo
echo "Make kernel/modules Done!"
echo

exit 0

