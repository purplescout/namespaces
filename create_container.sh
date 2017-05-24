#!/usr/bin/env bash


mkdir alpine_rootfs
wget https://nl.alpinelinux.org/alpine/v3.5/releases/x86_64/alpine-minirootfs-3.5.2-x86_64.tar.gz
tar xvf alpine-minirootfs-3.5.2-x86_64.tar.gz -C alpine_rootfs
rm alpine-minirootfs-3.5.2-x86_64.tar.gz


#unshare --user --mount --uts --net --ipc --pid --cgroup --map-root-user --fork bash
unshare -UrmunipCf bash


# Vi försäkrar oss om att våran root mount är privat för vårt namespace
mount --make-rprivate /
#  pivot_root kräver att det nya rotfilsystemet är en mount
mount --rbind alpine_rootfs alpine_rootfs
# Vi skapar ett proc filsystem
mount -t proc proc alpine_rootfs/proc


export PATH=$PATH:/bin:/sbin


# Vi skapar en katalog där vårt nuvarande rotfilsystem kommer monteras
mkdir alpine_roo	tfs/old_root
# Vi utför bytet och ställer oss i den nya roten
pivot_root alpine_rootfs alpine_rootfs/old_root && cd /
# Vi startar ett nytt shell
exec sh
# och avmonterar det gamla filsystemet
mount --make-rprivate /old_root && umount -l /old_root

