chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done
sed -i "s|VolGroup00/LogVol00|vg_root/lv_root|g" /boot/grub2/grub.cfg
exit
