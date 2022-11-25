cat << EOF | chroot /mnt/ /bin/bash
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done
pvcreate -y /dev/sdc /dev/sdd
vgcreate -y vg_var /dev/sdc /dev/sdd
lvcreate -y -L 950M -m1 -n lv_var vg_var
mkfs.ext4 /dev/vg_var/lv_var
mount /dev/vg_var/lv_var /mnt
rsync -avHPSAX /var/ /mnt/
umount /mnt
mount /dev/vg_var/lv_var /var
#echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
exit
EOF
