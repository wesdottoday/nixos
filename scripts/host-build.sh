#!/bin/sh

boot_nvme_dev=$(fdisk -l | grep 465.76 | sed -E 's/^\s*\S+\s+(\S+).*/\1/' | sed 's/\://')
boot_nvme_name=$(echo $boot_nvme_dev | sed -E 's/\/dev\///')
boot_nvme_name_p1="${boot_nvme_name}p1"
boot_nvme_name_p3="${boot_nvme_name}p3"
boot_nvme_by_id=$(ls -l /dev/disk/by-id | grep Samsung | grep $boot_nvme_name | head -1 | awk '{print $9}')
amnesia=0
echo $boot_nvme_dev
echo $boot_nvme_name
echo $boot_nvme_by_id
echo

echo Time to wipe partition the boot drive $boot_nvme_dev
read -p "Would you like to proceed wiping this drive? Y/N " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]];
then
    sgdisk -z /dev/disk/by-id/$boot_nvme_by_id
    sgdisk -n3:1M:+1024M -t3:EF00 /dev/disk/by-id/$boot_nvme_by_id
    sgdisk -n1:0:0 -t1:BF01 /dev/disk/by-id/$boot_nvme_by_id
    mkfs.vfat /dev/disk/by-id/$boot_nvme_by_id-part3
    echo Drive wiped and partitioned:
    echo
    sgdisk -p /dev/disk/by-id/$boot_nvme_by_id
fi

echo 
echo "Now we're going to setup luks encryption"
echo "Enter a password for disk encryption: "
read -s firstencryptionpass
echo 
read -s -p "Retype the password: " secondencryptionpass
echo
if [ $firstencryptionpass == $secondencryptionpass ];
then
    echo "Passwords matched, proceeding..."
    echo $firstencryptionpass | cryptsetup -q luksFormat /dev/disk/by-id/$boot_nvme_by_id-part1 crypt
    echo $firstencryptionpass | cryptsetup open --type luks /dev/disk/by-id/$boot_nvme_by_id-part1 crypt
fi

echo "Cool beans, let's do some ZFS stuffs"
echo 
read -p "Should we be cruel to this machine and give it amnesia? Y/N " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]];
then
    echo
    amnesia=1
    if [ -L "/dev/mapper/crypt" ]; then
        zpool create -O mountpoint=none -f rpool /dev/mapper/crypt
        zfs create -p -o mountpoint=legacy rpool/local/root
        zfs snapshot rpool/local/root@blank
        mount -t zfs rpool/local/root /mnt
        mkdir -p /mnt/{boot,nix,home,persist}
        mount /dev/$boot_nvme_name_p3 /mnt/boot
        zfs create -p -o mountpoint=legacy rpool/local/nix
        mount -t zfs rpool/local/nix /mnt/nix
        zfs create -p -o mountpoint=legacy rpool/safe/home
        mount -t zfs rpool/safe/home /mnt/home
        zfs create -p -o mountpoint=legacy rpool/safe/persist
        mount -t zfs rpool/safe/persist /mnt/persist
    else
        echo "/dev/mapper/crypt does not exist"
    fi
else
    echo
    if [ -L "/dev/mapper/crypt" ]; then
        zpool create -O mountpoint=none -f rpool /dev/mapper/crypt
        zfs create -p -o mountpoint=legacy rpool/local/root
        mount -t zfs rpool/local/root /mnt
        mkdir -p /mnt/{boot,nix,home}
        mount /dev/$boot_nvme_name_p3 /mnt/boot
        zfs create -p -o mountpoint=legacy rpool/local/nix
        mount -t zfs rpool/local/nix /mnt/nix
        zfs create -p -o mountpoint=legacy rpool/safe/home
        mount -t zfs rpool/safe/home /mnt/home
    else
        echo "/dev/mapper/crypt does not exist"
    fi
fi