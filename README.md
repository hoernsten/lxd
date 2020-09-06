### Description
This repository contains various bash scripts created with the intention of making lxd container creation and maintenance quicker and easier.

### Prerequisites
In order to guarantee a flawless execution, there are certain criteria that should be met.

* The host server is running Ubuntu 18.04 or 20.04
* The storage backend is either zfs or btrfs
* Quotas are enabled for the storage backend of choice

This is not to say you will not be able to run the scripts using any other setup, but this is the environment in which they have been tested and confirmed to work without major issues.

### Installation
Download the and run the installation script on the host server.

```
wget https://raw.githubusercontent.com/hoernsten/lxd/master/install.sh
chmod +x install.sh
sudo ./install.sh
```
It will then be installed to /opt/lxd, and a symbolic link will be created in /usr/local/bin.

Remember to make sure the current user is a member of the lxd group.

```
groups $USER | grep -o lxd
```

### Usage

Use the *ct* command followed by the module name to invoke it, then enter any values as needed when prompted. For example, to create a new container you would run *ct create*, enter a few values and then you're done.

```
user@ubuntu:~$ ct create
Container name [default=random]: c1
Container image [default=ubuntu:18.04]: ubuntu:18.04
Container disk quota (e.g. 500MB or 10GB) [default=5GB]: 10GB
Container memory limit (e.g. 512MB or 4GB) [default=512MB]: 1024MB
Container CPU core count limit (1-4) [default=1]: 2
Container CPU priority (1-10) [default=5]: 8
Container profile [default=default]: default
Autostart container at boot time (yes/no) [default=no]: yes
Enter storage pool [default=default]: default
Creating c1
Starting c1
user@ubuntu:~$
user@ubuntu:~$ lxc list
+-----------+---------+--------------------+------+------------+-----------+
|   NAME    |  STATE  |        IPV4        | IPV6 |    TYPE    | SNAPSHOTS |
+-----------+---------+--------------------+------+------------+-----------+
| c1        | RUNNING | 192.168.0.5 (eth0) |      | PERSISTENT |           |
+-----------+---------+--------------------+------+------------+-----------+
```
### Upcoming Features
* The ability to preseed the create module
* A basic host installation and configuration script
