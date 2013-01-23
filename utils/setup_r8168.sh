#!/bin/bash

# kernel-develがはいってないとダメよ

cd /usr/local/src
wget http://r8168.googlecode.com/files/r8168-8.032.00.tar.bz2
tar -jxvf r8168-8.032.00.tar.bz2
cd r8168-8.032.00
make clean modules
make modules
make install

/sbin/depmod -a
/sbin/modprobe r8168

sed -i s/r8169/r8168/ /etc/modprobe.conf

echo 'Done.'

