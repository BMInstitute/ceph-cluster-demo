#!/bin/sh -e

echo ":) start to copy ceph.repo ... "
cp /tmp/ceph.repo /etc/yum.repos.d/ceph-deploy.repo
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

echo ":) start to add keyserver ... "
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

gpg --keyserver pgp.mit.edu --recv-key 7F438280EF8D349F
gpg --list-key --fingerprint 7F438280EF8D349F

echo ":) start to update ... "
yum -y update

echo ":) start to install support tools ... "
#yum -y install ceph-deploy
yum -y install deltarpm
#yum -y install ntp ntpdate ntp-doc
yum -y install openssh-server
#yum -y install subscription-manager
yum -y install rsync dos2unix iotop lsof man tmux bash-completion locate
#yum -y install yum-plugin-priorities

#echo ":) start to enable 'rhel-7-server-extras-rpms' ... "
#subscription-manager repos --enable=rhel-7-server-extras-rpms

echo ":) start to update again ... "
yum -y update
#yum -y upgrade

yum -y autoremove

echo ":) start to check the ceph node user ... "
if ! id -u fengzhiguo > /dev/null 2>&1 ; then
  echo ":) start to add the node user ... "
  useradd fengzhiguo -u 10000 -m -s /bin/bash > /dev/null 2>&1
  rsync -a /etc/skel/ /home/fengzhiguo/

  echo ":) start to copy ssh & authorized_keys ... "
  mkdir /home/fengzhiguo/.ssh
  cp /home/vagrant/.ssh/authorized_keys /home/fengzhiguo/.ssh/
  chmod 0700 /home/fengzhiguo/.ssh

  echo ":) start to accellerate ssh login ... "
  touch /home/fengzhiguo/.hushlogin
  mv /tmp/.bashrc /home/fengzhiguo/
  dos2unix /home/fengzhiguo/.bashrc >/dev/null 2>&1
  chown fengzhiguo:fengzhiguo -R /home/fengzhiguo/

  echo ":) start to enable NOPASSWD ... "
  echo "fengzhiguo ALL = (root) NOPASSWD:ALL" | tee /etc/sudoers.d/fengzhiguo
  chmod 0440 /etc/sudoers.d/fengzhiguo

  echo ":) start to continue nopasswd configuring ... "
  chmod 0666 /etc/ssh/sshd_config
  echo >> /etc/ssh/sshd_config
  echo "UseDNS no" >> /etc/ssh/sshd_config
  echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
  chmod 0600 /etc/ssh/sshd_config
  service sshd reload

  echo ":) start to set the timezone to Asia/Shanghai ... "
  timedatectl set-timezone Asia/Shanghai

fi

