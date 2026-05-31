#!/bin/bash

make clean;
mkdir $USER
cp -r escape_game non_comm_reduction combine producer_consumer bin_update $USER;
cd $USER; find . -not \( -name  "*.c" -or  -name "Makefile" -or -name "*.h" -or -type d \) | xargs rm; cd ..;
tar zcvf $USER.tgz $USER;
rm -rf $USER;
