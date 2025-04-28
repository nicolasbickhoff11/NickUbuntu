#!/data/data/com.termux/files/usr/bin/bash
clear
apt install proot tar wget -y
if [ "$(uname -m)" == "aarch64" ]; then
LINK="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-arm64.tar.gz"
elif [ "$(uname -m)" == "armv7l" ]; then
LINK="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-armhf.tar.gz"
elif [ "$(uname -m)" == "x86_64" ]; then
LINK="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-amd64.tar.gz"
else
echo "Erro: Rootfs não encontrado para essa arquitetura."
exit 1
fi
ROOTFS_PATH="$HOME/ubuntu-fs"
CACHE_DIR="$HOME/.cache_dir"
ARCHIVE_NAME="ubuntu-base-22.04-base-$(uname -m).tar.gz"
if [ -d "$ROOTFS_PATH" ]; then
   echo "O Ubuntu já está instalado"
   exit 1
else
   mkdir -p "$ROOTFS_PATH"
   mkdir -p "$CACHE_DIR"
   echo -e "\e[1;32m[*] Baixando Ubuntu...\e[0m"
   wget "$LINK" -O "$CACHE_DIR/$ARCHIVE_NAME"
   echo -e "\e[1;32m[*] Extraindo Ubuntu...\e[0m"
   proot -l tar -xf "$CACHE_DIR/$ARCHIVE_NAME" -C "$ROOTFS_PATH"
   rm -rf "$HOME/.cache_dir"
   echo -e "\e[1;32m[*] Criando Script...\e[0m"
   cat << EOF > $HOME/start-ubuntu.sh
unset LD_PRELOAD
rootfs="$HOME/ubuntu-fs"
command="proot -k 6.8.0 -l -0 -r \$rootfs "
command+=" -b /proc "
command+=" -b /dev "
command+=" -b /sys "
command+=" -b /:/host-rootfs "
command+=" -w /root "
command+=" /bin/su - "
exec \$command
EOF
echo "nameserver 1.1.1.1" > $HOME/ubuntu-fs/etc/resolv.conf
id | sed 's/.*groups=//' | tr ',' '\n' \
| sed -E 's/([0-9]+)\(([^)]+)\)/\2:x:\1:/' \
| grep -vE '^u0_[^_]+$' \
| grep -v '^c[0-9]\+$' \
| cut -d' ' -f1 \
>> $HOME/ubuntu-fs/etc/group
echo "127.0.0.1 localhost ::1" > $HOME/ubuntu-fs/etc/hosts

unset LD_PRELOAD
proot -l -0 -r "$HOME/ubuntu-fs" -b /proc -b /dev -b /sys -w /root /usr/bin/env -i HOME=/root TERM=$TERM /bin/bash -c "apt update && apt upgrade -y && apt install sudo vim tzdata wget curl -y"
chmod +x $HOME/start-ubuntu.sh
echo "YOU CAN START UBUNTU WITH ~/start-ubuntu.sh"
exit 1
fi
