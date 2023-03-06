#!/bin/sh

    if [ "`id -u`" -ne 0 ]; then
        echo "sudo do as root!"
        exit 1
    fi

    if [ $# -ne 1 ]; then
      echo "usage: $0 dir"
      exit 1
    fi

    if [ ! -d "$1" ]; then
      echo "First argument must be a directory"
      exit 1
     fi

HostLib=hostlib

LIB=lib/x86_64-linux-gnu/
USR=usr/lib/x86_64-linux-gnu/

    rm -fr $HostLib
    mkdir $HostLib $HostLib/lib $HostLib/$LIB $HostLib/lib64 $HostLib/usr  $HostLib/usr/lib $HostLib/$USR

	for file in c dl nsl \
            m pthread resolv rt util nsl nss_dns \
			nss_files nss_compat anl
    do
    	cp -a /lib/x86_64-linux-gnu/lib$file-*.so $HostLib/$LIB
    	cp -a /lib/x86_64-linux-gnu/lib$file.so.[*0-9] $HostLib/$LIB
	done

	cp -a /lib/x86_64-linux-gnu/ld-2.*.so $HostLib/$LIB
	cp -a /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 $HostLib/$LIB


#	for file in gcc_s blkid ss selinux
	for file in gcc_s blkid uuid crypt selinux lzma pcre2-8
    do
    	cp -a /lib/x86_64-linux-gnu/lib$file.so.* $HostLib/$LIB
	done

# libstdc++, libcrypto libform libpanel libmenu libncurses libxml2 libkmod libpcre2-8
### /usr/lib
#	for file in jpeg png12 gssapi_krb5 k5crypto krb5support krb5 stdc++ edit \

	for file in stdc++ curl curl-gnutls ssl crypto kmod
		do
			cp -a /usr/lib/x86_64-linux-gnu/lib$file.so* $HostLib/$USR
		done
        rm -fr $HostLib/$USR/libcrypto.so.1.0.0

#	for file in stdc++
#		do
#			cp -a /usr/lib/lib$file.so.[5-9]* lib
#		done
# ssl cap attr

	for file in com_err ncurses ext2fs z expat pcre
		do
			cp -a /lib/x86_64-linux-gnu/lib$file.so* $HostLib/$LIB
		done

        cp -a /lib64/ $HostLib

#	for file in ssl crypto
#
#		do
#			cp  -a /lib/lib$file.so* lib
#		done

#	strip $HostLib/$LIB/*.so*
	chmod +x $HostLib/$LIB/*.so.*

#	strip $HostLib/$USR/*.so*
	chmod +x $HostLib/$USR/*.so.*

cat  >$HostLib/$USR/libgcc_s.so <<EOF
GROUP ( libgcc_s.so.1 -lgcc )
EOF

    if [ ! "$?" = 0 ]; then
        echo
        echo "get lib error!"
        echo
        exit 1
    fi

    sudo cp -a $HostLib/* $1/

    if [ ! "$?" = 0 ]; then
        echo
        echo "copy to $1 error!"
        echo
        exit 1
    fi

    echo "Done!"

    exit 0

    rm -fr $HostLib

