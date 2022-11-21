# -*- mode: ruby -*-
# vim: set ft=ruby :
home = ENV['HOME']
ENV["LC_ALL"] = "en_US.UTF-8"

MACHINES = {
  :lvm => {
        :box_name => "centos/7",
        :box_version => "1804.02",
        :ip_addr => '192.168.11.101',
    :disks => {
        :sata1 => {
            :dfile => home + '/VirtualBox VMs/sata1.vdi',
            :size => 10240,
            :port => 1
        },
        :sata2 => {
            :dfile => home + '/VirtualBox VMs/sata2.vdi',
            :size => 2048, # Megabytes
            :port => 2
        },
        :sata3 => {
            :dfile => home + '/VirtualBox VMs/sata3.vdi',
            :size => 1024, # Megabytes
            :port => 3
        },
        :sata4 => {
            :dfile => home + '/VirtualBox VMs/sata4.vdi',
            :size => 1024,
            :port => 4
        }
    }
  },
}

Vagrant.configure("2") do |config|

    config.vm.box_version = "1804.02"
    MACHINES.each do |boxname, boxconfig|
  
        config.vm.define boxname do |box|
  
            box.vm.box = boxconfig[:box_name]
            box.vm.host_name = boxname.to_s
  
            #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset
  
            box.vm.network "private_network", ip: boxconfig[:ip_addr]
  
            box.vm.provider :virtualbox do |vb|
                    vb.customize ["modifyvm", :id, "--memory", "256"]
                    needsController = false
            boxconfig[:disks].each do |dname, dconf|
                unless File.exist?(dconf[:dfile])
                  vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                  needsController =  true
                            end
  
            end
                    if needsController == true
                       vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                       boxconfig[:disks].each do |dname, dconf|
                           vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                       end
                    end
            end
  
        box.vm.provision "shell", inline: <<-SHELL
            mkdir -p ~root/.ssh
            cp ~vagrant/.ssh/auth* ~root/.ssh
            yum install -y mdadm smartmontools hdparm gdisk xfsdump wget vim
	        sudo -i
		echo "LVM_itsvetkov" > /etc/hostname
		echo "CREATING LVM"
		pvcreate /dev/sdb
		vgcreate vg_root /dev/sdb
		lvcreate -n lv_root -l +100%FREE /dev/vg_root
		mkfs.xfs /dev/vg_root/lv_root
		mount /dev/vg_root/lv_root /mnt
		xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
		echo "REPORT /mnt"
		ls -lsa /mnt
		echo "-------END REPORT-------"
		for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
		echo "START"
		wget -P /root/  https://raw.githubusercontent.com/tsvetkovivan1993/homework3/main/chroot.sh
		chmod +x /root/chroot.sh
		bash 	/root/chroot.sh | tee /root/reportCHROT.txt
 		
#	config.vm.provision :reload

#  	config.vm.provision "shell", inline: <<-SHELL
#                lsblk
# 	SHELL
#		echo "#!/bin/sh" >> /root/changeVol.sh
#		echo "lvremove /dev/VolGroup00/LogVol00" >> /root/changeVol.sh
#		echo "lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00" >> /root/changeVol.sh
#		echo "mkfs.xfs /dev/VolGroup00/LogVol00" >> /root/changeVol.sh
#		echo "mount /dev/VolGroup00/LogVol00 /mnt" >> /root/changeVol.sh
#		echo "xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt" >> /root/changeVol.sh
#		echo "for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done" >> /root/changeVol.sh
#		echo "chroot /mnt/" >> /root/changeVol.sh
#		echo "grub2-mkconfig -o /boot/grub2/grub.cfg" >> /root/changeVol.sh
#		echo "cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done" >> /root/changeVol.sh
#		echo "pvcreate /dev/sdc /dev/sdd" >> /root/changeVol.sh
#		echo "vgcreate vg_var /dev/sdc /dev/sdd" >> /root/changeVol.sh
#		echo "lvcreate -L 950M -m1 -n lv_var vg_var" >> /root/changeVol.sh
#		echo "mkfs.ext4 /dev/vg_var/lv_var" >> /root/changeVol.sh
#		echo "mount /dev/vg_var/lv_var /mnt" >> /root/changeVol.sh
#		echo "rsync -avHPSAX /var/ /mnt/" >> /root/changeVol.sh
#		echo "umount /mnt" >> /root/changeVol.sh
#		echo "mount /dev/vg_var/lv_var /var" >> /root/changeVol.sh
#		echo "echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab" >> /root/changeVol.sh 
#		echo "'@reboot sleep 50 && /root/changeVol.sh' >> /etc/crontab" >> /root/changeVol.sh
#		cat /root/changeVol.sh
#		bash /root/changeVol.sh
#		echo "crontab list"
#		cat /etc/crontab
#		lsblk

          SHELL
  
        end
    end
  end
  
