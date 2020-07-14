#!/bin/bash

# Settings
if_device="eth0"
if_bridge="br0"
pool_device="/dev/sda2"
pool_name="local"
pool_description="Local btrfs storage"
pool_fs="btrfs"
pool_mount="/mnt/local"
profile_name="default"
profile_description="Default profile"
dhcp="no"
ip="192.168.0.2/24"
gateway="192.168.0.1"
dns1="8.8.8.8"
dns2="8.8.4.4"
domain="example.com"
wol="true"
timezone="UTC"
target="/opt/lxd"

# Check if the script is running with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Not running as root"
  exit
fi

# Check if the parent interface exists
while ! ip link show $if_device > /dev/null 2>&1; do
  echo "Error: No $if_device interface was found"
  read -p "Enter parent interface: " if_device
done

# Verify connectivity before proceeding
connectivity_check () {
  if dpkg-query -l | grep -oq iputils-ping; then
    while ! ping -c 3 -W 1 archive.ubuntu.com > /dev/null 2>&1; do
      echo "Network: Unable to reach archive.ubuntu.com"
      sleep 3
    done
  else
    apt-get -y install iputils-ping
    while ! ping -c 3 -W 1 archive.ubuntu.com > /dev/null 2>&1; do
      echo "Network: Unable to reach archive.ubuntu.com"
      sleep 3
    done
  fi
}

# Allow SSH and enable ufw
sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
ufw allow 22/tcp
ufw enable

# Create a bridge interface
echo "network:
  version: 2
  renderer: networkd
  ethernets:
    $if_device:
      dhcp4: no
      wakeonlan: $wol
  bridges:
    $if_bridge:
      interfaces: [$if_device]
      dhcp4: $dhcp" > $(ls /etc/netplan/*.yaml | head -1)

if [ $dhcp == "no" ]; then
  echo "      addresses: [$ip]
      gateway4: $gateway
      nameservers:
        search: [$domain]
        addresses: [$dns1, $dns2]" >> $(ls /etc/netplan/*.yaml | head -1)
fi

# Apply the network configuration
netplan apply
sleep 3
connectivity_check

# Upgrade the system and install packages
apt-get -y update
apt-get -y upgrade
apt-get -y install snapd openssh-server unattended-upgrades sysstat
apt-get -y remove --purge lxd lxd-client liblxc1 lxcfs
apt-get -y autoremove

# Install ZFS
if [ $pool_fs == "zfs" ]; then
  modprobe zfs
  apt-get -y install zfsutils-linux
fi

# Install LXD and Canonical Livepatch
snap install lxd canonical-livepatch
snap refresh lxd

# Initialize LXD with preseeded config
cat <<EOF | lxd init --preseed
config: {}
networks: []
storage_pools:
- config:
    source: $pool_device
  description: "$pool_description"
  name: $pool_name
  driver: $pool_fs
profiles:
- config: {}
  description: "$profile_description"
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: $if_bridge
      type: nic
    root:
      path: /
      pool: $pool_name
      type: disk
  name: $profile_name
cluster: null
EOF

# Create a mount point and mount the LXD pool partition
if [ ! -z $pool_mount ]; then
  mkdir -p $pool_mount
  mount $pool_device $pool_mount
  echo "UUID=$(blkid -o value -s UUID $pool_device)	$pool_mount	$pool_fs	defaults		0	2" >> /etc/fstab
fi

# Enable btrfs quota
if [ $pool_fs == "btrfs" ]; then
  btrfs quota enable $pool_mount
fi

# Add the minimal Ubuntu images to the remote image list and download
lxc remote add --protocol simplestreams ubuntu-minimal https://cloud-images.ubuntu.com/minimal/releases/
lxc image copy ubuntu-minimal:18.04 local: --alias "ubuntu:18.04" --auto-update

# Enable automatic upgrades
echo 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";' > /etc/apt/apt.conf.d/20auto-upgrades
systemctl restart unattended-upgrades

# Set the system timezone
timedatectl set-timezone $timezone

# Create the target directory
if [[ ! -d $target ]]; then
    mkdir -p $target
fi

# Download and extract
wget -P $target https://github.com/hoernsten/lxd/archive/master.tar.gz
tar --strip-components=1 -xzvf $target/master.tar.gz -C $target

# Modify permissions
chgrp lxd $target/ct
chmod u=rwx,g=rx,o=r $target/ct

# Create a symlink
if [ ! -f /usr/local/bin/ct ]; then
    ln -s $target/ct /usr/local/bin/
fi
