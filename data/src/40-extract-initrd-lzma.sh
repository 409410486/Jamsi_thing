#!/bin/bash
    if [ $# -ne 1 ]
    then
      echo "usage: $0 lzma-file"
      exit 1
    fi

    if [ "`id -u`" -ne 0 ]; then
        echo "sudo do as root!"
        exit 1
    fi

    rm -fr system
    mkdir -p system
    cd system
    lzcat  < ../$1 | sudo cpio -i -H newc -d

    echo "Done!"

    exit 0
