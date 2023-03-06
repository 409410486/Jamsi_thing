#!/bin/sh

KernelVersion=5.10.27

    if [ $# -ne 1 ]
    then
      echo "usage: $0 dir"
      exit 1
    fi

    if [ "`id -u`" -ne 0 ]; then
        echo "sudo do as root!"
        exit 1
    fi

    if [ -d "$1" ]
    then
        echo "remove old modules... "
        rm -fr "$1/lib/modules"

        echo "copyng modules to $1"
        cp -a linux-$KernelVersion/drv/lib/modules "$1/lib/"
        exit 0
    else
      echo "First argument must be a directory"
      exit 1
     fi

