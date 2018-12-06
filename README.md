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

Run the ct-get script on the LXD host to download the latest and greatest this repository has to offer.

```
sudo ./ct-get
```

From then on you’ll be able to run all scripts simply by invoking them. Just remember to make sure the current user is a member of the lxd group before doing so.

```
groups $USER | grep -o lxd
```

### Usage

To create a new container, use *ct create*. You’ll be asked whether you want to run the configuration script during the creation process, which is something you’ll probably want to do, but this is not required.

```
ct create ct1
```

I recommend finishing the container creation process by creating a snapshot immediately after.

```
lxc snapshot ct1 snap_$(date '+%Y-%m-%d')
```

To update the running containers, use *ct update* and either specify the container names or update all of them in a single go.

```
ct update all
ct update ct1 ct2 ...
```

Use *ct get* to keep the scripts up-to-date.

```
sudo ct get
```
