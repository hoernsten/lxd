### Description
This repository contains various bash scripts created with the intention of making lxd container creation and maintenance quicker and easier.

### Prerequisites
In order to guarantee a flawless execution, there are certain criteria that should be met.

* The host device is running Ubuntu 18.04 LTS
* The lxd snap is installed and up to date
* LXD has already been configured
* The storage backend is either zfs or btrfs
* Quotas are enabled for the storage backend of choice

This is not to say you will not be able to run the scripts using any other setup, but this is the environment in which they have been tested and confirmed to work without major issues.

### Installation
Download the repository, extract it and run the install script.

```
wget https://github.com/hoernsten/lxd/archive/master.tar.gz
tar xzvf master.tar.gz
sudo lxd-master/install
```
It will then be installed to /opt/lxd, and a symbolic link will be created in /usr/local/bin.

Remember to make sure the current user is a member of the lxd group.

```
groups $USER | grep -o lxd
```

### Usage

Use the *ct* command followed by the module name to invoke it, then enter any values as needed when prompted. For example, to create a new container you would run *ct create*, enter a few values and then you're done.

```
lxduser@ubuntu:~$ ct create
Enter container name: c1
Enter container image [default=ubuntu/18.04]: ubuntu/18.04
Enter container disk quota (e.g. 500MB or 10GB) [default=5GB]: 10GB
Enter container memory limit (e.g. 512MB or 4GB) [default=512MB]: 1024MB
Enter container CPU core count limit (1-4) [default=1]: 2
Enter container CPU priority (1-10) [default=5]: 8
Enter container profile [default=default]: default
Enter storage pool [default=default]: local
Copying image
Image copied successfully!
Creating c1
Creating snapshot
Starting c1
lxduser@ubuntu:~$
lxduser@ubuntu:~$ lxc list
+-----------+---------+--------------------+------+------------+-----------+
|   NAME    |  STATE  |        IPV4        | IPV6 |    TYPE    | SNAPSHOTS |
+-----------+---------+--------------------+------+------------+-----------+
| c1        | RUNNING | 192.168.0.2 (eth0) |      | PERSISTENT | 1         |
+-----------+---------+--------------------+------+------------+-----------+
```
### Upcoming Features
* The ability to preseed the create module
* A basic host installation and configuration script
