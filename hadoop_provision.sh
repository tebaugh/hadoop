#!/usr/bin/env bash
# This is looking for a file on the VM.  If found the VM is already provisioned
if [ -f "/var/vagrant_provision" ]; then
  exit 0
fi
echo "Installing wget...."
yum install -y wget >/dev/null 2>&1
echo "Getting RPMforge rlease package..."
wget -c http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm >/dev/null 2>&1
echo "Install DAGs GPG Key...."
rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt >/dev/null 2>&1
echo "Verify the package...and install"
rpm -K rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Unable to verify package"
  exit 1
fi
rpm -i rpmforge-release-0.5.3-1.el6.rf.*.rpm >/dev/null 2>&1
echo "Installing dkms ...."
yum --enablerepo rpmforge install -y dkms >/dev/null 2>&1
echo "install gcc and make ..."
yum install -y gcc >/dev/null 2>&1
yum install -y make >/dev/null 2>&1
echo "install kernel-devel...."
yum install -y  kernel-devel >/dev/null 2>&1
echo "update OS..."
yum update  -y  >/dev/null 2>&1
echo "Installing GuestAdditions ...."
wget -c http://download.virtualbox.org/virtualbox/4.3.0/VBoxGuestAdditions_4.3.0.iso >/dev/null 2>&1
umount /mnt >/dev/null 2>&1
echo "Mounting GuestAdditions .... "
mount VBoxGuestAdditions_4.3.0.iso -o loop /mnt >/dev/null 2>&1
echo "Mounting LinuxAdditions...."
sh /mnt/VBoxLinuxAdditions.run >/dev/null 2>&1
echo "g++ needed to compile Protocol Buffers .... installing ...."
sudo yum install -y gcc-c++ >/dev/null 2>&1
echo "downloading Protocol Buffers ....."
wget -c https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz >/dev/null 2>&1
echo "expanding Protocol Buffers"
tar -zxvf protobuf-2.5.0.tar.gz >/dev/null 2>&1
cd protobuf-2.5.0
echo "Configuring Protocol Buffers.  Needed only if building hadoop via source ... "
./configure >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Unable to configure Protocol Buffers...."
  exit 1
fi
echo "Running make on Protocol Buffers....."
make >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Unable to make Protocol Buffers...."
  exit 1
fi
make check >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Make check failed on Protocol Buffers...."
  exit 1
fi
make install >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Installing Protocol Buffers failed...."
  exit 1
fi
echo "Downloading hadoop....."
cd ~ >/dev/null 2>&1
wget -c http://apache.mirrors.pair.com/hadoop/common/hadoop-2.2.0/hadoop-2.2.0.tar.gz >/dev/null 2>&1
echo "expanding hadoop ....."
tar -zxvf hadoop-2.2.0.tar.gz >/dev/null 2>&1
touch "/var/vagrant_provision"
echo "rebooting now..."
reboot now

