#!/bin/sh -e

# 24 Dec 2015 : GWA : Minimal box is very minimal. Use to get
# add-apt-repository, updatedb, tmux.
mv /etc/apt/sources.list /etc/apt/sources.list.bak
cp /tmp/sources.list /etc/apt/sources.list

gpg --keyserver keyserver.ubuntu.com --recv-keys  16126D3A3E5C1192
gpg -a --export  16126D3A3E5C1192 | sudo apt-key add -

echo "start to update ..."
apt-get -y update
apt-get -y install software-properties-common locate tmux bash-completion man lsof iotop dos2unix
#add-apt-repository ppa:geoffrey-challen/os161-toolchain > /dev/null 2>&1 && true
#add-apt-repository ppa:git-core/ppa > /dev/null 2>&1 && true

#echo "set grub-pc/install_devices /dev/sda" | debconf-communicate
apt-get -y update
apt-get -y upgrade

echo "start to install wget"
apt-get -y install wget

# 24 Dec 2015 : GWA : Install OS/161 toolchain and Git.
#apt-get install -y os161-toolchain git git-doc

wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
echo deb https://download.ceph.com/debian-jewel/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list

echo "start to update ..."
apt-get -y update

echo "start to install ceph-deploy ..."
apt-get -y install ceph-deploy

echo "start to autoremove ..."
apt-get autoremove -y

echo "start to create the user [fengzhiguo] ..."
# 24 Dec 2015 : GWA : Bootstrap fengzhiguo user.
if ! id -u fengzhiguo > /dev/null 2>&1 ; then
	useradd fengzhiguo -u 10000 -m -s /bin/bash > /dev/null 2>&1
	rsync -a /etc/skel/ /home/fengzhiguo/

        echo "start to configure the .ssh key ..."
	mkdir /home/fengzhiguo/.ssh
	#mkdir /home/fengzhiguo/src

	cp /home/vagrant/.ssh/authorized_keys /home/fengzhiguo/.ssh/
	chmod 0700 /home/fengzhiguo/.ssh

        echo "start to set no password ..."
	echo "fengzhiguo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/fengzhiguo

	touch /home/fengzhiguo/.hushlogin
	mv /tmp/.bashrc /home/fengzhiguo/

        echo "start to execute the command dos2unix ..."
	dos2unix /home/fengzhiguo/.bashrc >/dev/null 2>&1
	chown fengzhiguo:fengzhiguo -R /home/fengzhiguo/

	# 24 Dec 2015 : GWA : Try to speed up SSH. Doesn't help much.
	echo >> /etc/ssh/sshd_config
	echo "UseDNS no" >> /etc/ssh/sshd_config
	echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
	service ssh reload

	#echo "America/New_York" > /etc/timezone
	echo "Asia/Shanghai" > /etc/timezone
	dpkg-reconfigure --frontend noninteractive tzdata 2>/dev/null
fi

# 24 Dec 2015 : GWA : Remount shared folders with correct ownership on
# every boot.
mv /tmp/sharedfolders.conf /etc/init/
chown root:root /etc/init/sharedfolders.conf
mount -t vboxsf -o uid=10000,gid=10000 home_fengzhiguo_src /home/fengzhiguo/src

updatedb
