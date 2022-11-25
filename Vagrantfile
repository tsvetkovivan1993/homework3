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
		echo "LVMitsvetkov" > /etc/hostname
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
		bash 	/root/chroot.sh
		echo "FINISH"
  	    SHELL

#REBOOT
box.vm.provision :shell do |shell|
    shell.privileged = true
    shell.inline = 'echo rebooting'
    shell.reboot = true
end

#change root dir on 8 Gb and Var add
        box.vm.provision "shell", inline: <<-SHELL
		sudo -i
		lsblk
		hostnamectl
		lvremove -f /dev/VolGroup00/LogVol00
		lvcreate -y -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
		mkfs.xfs /dev/VolGroup00/LogVol00
		mount /dev/VolGroup00/LogVol00 /mnt
		xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
		for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
                echo "START Change root on 8 Gb and VAR"
		wget -P /root/  https://raw.githubusercontent.com/tsvetkovivan1993/homework3/c8803ea56915eb51a52a60c7208cb27338d63e25/chroot_on8gb.sh
                chmod +x /root/chroot_on8gb.sh
                bash    /root/chroot_on8gb.sh
                echo "FINISH"
		lsblk
		echo "fstab report"
		cat /etc/fstab
		echo "ROOT DIR size"
		echo "------------------"
		df -h /
		echo "------------------"
            SHELL
#REBOOT
box.vm.provision :shell do |shell|
    shell.privileged = true
    shell.inline = 'echo rebooting'
    shell.reboot = true
end
#add home in mirror _ snapshots
        box.vm.provision "shell", inline: <<-SHELL
                sudo -i
		cat /etc/fstab
#del last string
		sed -i -e '$d'  /etc/fstab
		cat /etc/fstab
		lvremove -y /dev/vg_root/lv_root
		vgremove -y /dev/vg_root
		pvremove -y /dev/sdb
		lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
		mkfs.xfs /dev/VolGroup00/LogVol_Home
		mount /dev/VolGroup00/LogVol_Home /mnt/
		cp -aR /home/* /mnt/ 
		rm -rf /home/*
		umount /mnt
		mount /dev/VolGroup00/LogVol_Home /home/
		echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
		touch /home/file{1..20}
		ls -lsa /home
		lvcreate -y -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
		rm -f /home/file{11..20}
		ls -lsa /home
		umount /home
		lvconvert --merge /dev/VolGroup00/home_snap
		mount /home
		ls -lsa /home/
		echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
		mount -a
		lsblk
#BTRFS
		echo "BTRFS START"
		pvcreate -y /dev/sdb /dev/sde
		vgcreate -y vg_btrsf /dev/sd{e,b}
		lvcreate -y -L 100M -m1 -n lv_btrsf vg_btrsf
		mkfs.btrfs /dev/vg_btrsf/lv_btrsf
		mount /dev/vg_btrsf/lv_btrsf /opt
		echo "`blkid | grep btrfs|head -n1  | awk '{print $2}'` /opt btrfs defaults 0 0" >> /etc/fstab 
		mount -a
		touch /opt/file_onbtrfs{1..20}
		umount -f /opt
		lvcreate -y -L 100MB -s -n opt_snapshot /dev/vg_btrsf/lv_btrsf
		echo "PVS"
		pvs
		echo "VGS"
		vgs
		echo "LVS"
		lvs
		echo "FINISH"
		mount -a
		lsblk
		echo "All log in vagrant console"
            SHELL
        end
    end
  end
  
