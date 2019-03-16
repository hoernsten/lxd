### Description
This repository contains various bash scripts created with the intention of making lxd container creation and maintenance quicker and easier.

### Prerequisites
In order to guarantee a flawless execution, there are certain criteria that should be met.

* The host device is running Ubuntu 18.04 LTS
* The lxd snap is installed and up to date
* LXD has already been configured by running *lxd init*
* The storage backend used is either zfs or btrfs

This is not to say you will not be able to run the scripts using any other setup, but this is the environment in which they have been tested and confirmed to work without major issues.

### Deployment
First, make sure you are running the latest version of the LXD snap package.

```
sudo snap refresh lxd
```

Then download the repository, extract it and run the install script.

```
wget https://github.com/hoernsten/lxd/archive/master.tar.gz
tar xzvf master.tar.gz
sudo lxd-master/install

```

Remember to make sure the current user is a member of the lxd group.

```
groups $USER | grep -o lxd
```

### Usage

Use the *ct* command followed by the module name to invoke it.

```
ct create
ct exec
ct update
...
```
