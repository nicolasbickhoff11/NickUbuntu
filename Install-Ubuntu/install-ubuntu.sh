#!/bin/bash

wget https://partner-images.canonical.com/core/focal/current/ubuntu-focal-core-cloudimg-arm64-root.tar.gz -O tmp.tar.gz

mkdir -p ~/ubuntu

proot -l tar -xvf tmp.tar.gz -C ~/ubuntu

rm tmp.tar.gz

echo "unset LD_PRELOAD" > ~/start-ubuntu.sh

echo "proot --kill-on-exit --link2symlink -0 -r ~/ubuntu -b /dev -b /proc -b /sys -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin TERM=$TERM LANG=C.UTF-8 /usr/bin/bash --login" >> ~/start-ubuntu.sh

chmod +x ~/start-ubuntu.sh

touch ~/ubuntu/root/.hushlogin

mv ~/ubuntu/etc/resolv.conf ~/ubuntu/etc/resolv.backup

echo "nameserver 8.8.8.8" > ~/ubuntu/etc/resolv.conf

clear
echo "Você pode executar Ubuntu de novo a partir do comando ~/start-ubuntu.sh" && ~/start-ubuntu.sh 
