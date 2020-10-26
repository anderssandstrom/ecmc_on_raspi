# ecmc_on_raspi

## Install from scratch: choose default when install raspian (from boot)

### Install vs-code
```bash
$ wget https://packagecloud.io/headmelted/codebuilds/gpgkey -O - | sudo apt-key add -
$ curl -L https://raw.githubusercontent.com/headmelted/codebuilds/master/docs/installers/apt.sh | sudo bash
# can be started by:
$ code-oss
```

### Install Pre-reqs

```bash
$ sudo apt install -y  build-essential libtool automake tree dkms

# Install hgq
$ sudo apt-get install mercurial$ sudo apt-get install mercurial

# Kernel headers are needed:
$ sudo apt install raspberrypi-kernel-headers

# Other needed stuff
$ sudo apt install tree emacs ipmitool autoconf libtool automake m4 re2c tclx coreutils graphviz build-essential libreadline-dev libxt-dev tclsh
$ sudo apt install x11proto-print-dev libxmu-headers libxmu-dev libxmu6 libxpm-dev libxmuu-dev libxmuu1 libpcre++-dev libmotif-dev libsnmp-dev re2c darcs python-dev libnetcdf-dev libhdf5-dev libbz2-dev libxml2-dev libblosc-dev libtiff-dev libusb-dev libusb-1.0-0-dev libudev-dev libsystemd-dev linux-source mercurial libboost-dev libboost-regex-dev libboost-filesystem-dev libopencv-dev libpng-dev libraw1394-11 libtirpc-dev fonts-liberation logrotate curl symlinks dkms procserv

```

### install etherlab master on kernel 4.*
```bash
$ git clone https://github.com/icshwi/etherlabmaster
$ cd etherlabmaster

$ make init
# !!!!!!IMPORTANT TSC not availbe in ARM (Set ENABLE_CYCLES=NO)!!!!!!! 
$ echo "ENABLE_CYCLES = NO" > configure/CONFIG_OPTIONS.local
$ make build
$ make install
# probably not needed: $ make modules
# Ensure check so files are in /opt/etherlab/ maybe "make modules" is needed?! seems sometimes "make install" fails??
$ echo "ETHERCAT_MASTER0=eth0" > ethercatmaster.local
$ make dkms_add
$ make dkms_build
$ make dkms_install
$ make setup
$ sudo systemctl start ethercat
```

### install etherlab master on kernel 5.*

```bash
$ git clone https://github.com/icshwi/etherlabmaster
$ cd etherlabmaster

# Note: For 5.* kernels the etherlab commit id in etherlabmaster/configure/CONFIG_MODULE
#       needs to be atleast commit  53ce5e56d511

$ echo "EPICS_MODULE_TAG:=53ce5e56d511" > configure/CONFIG_MODULE.local
$ make init

# !!!!!!IMPORTANT TSC not availbe in ARM (Set ENABLE_CYCLES=NO)!!!!!!! 
$ echo "ENABLE_CYCLES = NO" > configure/CONFIG_OPTIONS.local

$ make build
$ make install
# probably not needed: $ make modules

# Ensure check so files are in /opt/etherlab/ maybe "make modules" is needed?! seems sometimes "make install" fails??

$ echo "ETHERCAT_MASTER0=eth0" > ethercatmaster.local

# NOTE: add raspian to scripts/etherlab_setup.bash and script/etherlab_setup_clean.bash (in r-pi-dev branch of icshwi/etherlabmaster)

$ make dkms_add
$ make dkms_build
$ make dkms_install
$ make setup

$ sudo systemctl start ethercat

```

### E3 epics 7
```bash
$ git clone https://github.com/icshwi/e3 e3-7.0.4
$ cd e3-7.0.4
$ ./e3_building_config.bash -r 3.3.0 -b 7.0.4 setup
$ bash e3.bash base
$ bash e3.bash req
# note  etherlab master needs to be installed before ecmc
$ bash e3.bash -ce mod
$ bash e3.bash -ce load
```
NOTE: If trouble. On a recent release of e3 there's a "bug" i a makefile. The error message is something like: "module name needs to be lower case..."
Please see slack e3 channel.
Basically you need to edit the file require/configure/RULES_E3
find "module_name_check" and comment the tree rows after with "#"

### python matplot lib working. Also see conda.txt in WIP dir. Probably better than the below
```bash
$ pip install matplotlib==2.0.2
$ sudo apt-get install python-gi-cairo
$ pip install pyepics
$ sudo apt-get update
```

## Issues

### TCL 
Sometimes e3 error during "bash e3,.bash req" with "package Tclx" not found.
This could be related to that berryconda have a version of tcl installed. Workaround:

```
#1. Move berryconda temprary:
$ cd 
$ mv berycondaxx_back
#2. Reinsatll Tclx
$ sudo apt install tclx
# 3. Move berryconda back..
```

### Etherlab issue for kernel 5.*

NOTE: Problem when try to install etherlab on kernel 5.4.51-v7l+. dkms_build fails with the following error:

DKMS make.log for etherlabmaster-1.5.2 for kernel 5.4.51-v7l+ (armv7l)
Wed 02 Sep 2020 10:46:22 AM CEST
make[2]: Entering directory '/usr/src/linux-headers-5.4.51-v7l+'
  CC [M]  /var/lib/dkms/etherlabmaster/1.5.2/build/examples/mini/mini.o
  CC [M]  /var/lib/dkms/etherlabmaster/1.5.2/build/devices/generic.o
  CC [M]  /var/lib/dkms/etherlabmaster/1.5.2/build/master/cdev.o
  CC [M]  /var/lib/dkms/etherlabmaster/1.5.2/build/master/coe_emerg_ring.o
  LD [M]  /var/lib/dkms/etherlabmaster/1.5.2/build/examples/mini/ec_mini.o
  CC [M]  /var/lib/dkms/etherlabmaster/1.5.2/build/master/datagram.o
  CC [M]  /var/lib/dkms/etherlabmaster/1.5.2/build/master/datagram_pair.o
/var/lib/dkms/etherlabmaster/1.5.2/build/master/cdev.c:91:14: error: initialization of ‘vm_fault_t (*)(struct vm_fault *)’ {aka ‘unsigned int (*)(struct vm_fault *)’} from incompatible pointer type ‘int (*)(struct vm_fault *)’ [-Werror=incompatible-pointer-types]
     .fault = eccdev_vma_fault
              ^~~~~~~~~~~~~~~~
/var/lib/dkms/etherlabmaster/1.5.2/build/master/cdev.c:91:14: note: (near initialization for ‘eccdev_vm_ops.fault’)
cc1: some warnings being treated as errors
make[4]: *** [scripts/Makefile.build:266: /var/lib/dkms/etherlabmaster/1.5.2/build/master/cdev.o] Error 1
make[4]: *** Waiting for unfinished jobs....
  LD [M]  /var/lib/dkms/etherlabmaster/1.5.2/build/devices/ec_generic.o
make[3]: *** [scripts/Makefile.build:500: /var/lib/dkms/etherlabmaster/1.5.2/build/master] Error 2
make[2]: *** [Makefile:1709: /var/lib/dkms/etherlabmaster/1.5.2/build] Error 2
make[2]: Leaving directory '/usr/src/linux-headers-5.4.51-v7l+'

Solution: use later commit of etherlab master. Change in configure/CONFIG_MODULE
-EPICS_MODULE_TAG:=0c011dc6dbc4
+EPICS_MODULE_TAG:=53ce5e56d511

or override with:

echo "EPICS_MODULE_TAG:=53ce5e56d511" > configure/CONFIG_MODULE.local

Then the normal workflow works

### E3 (module name needs to be lower case error..)
bash e3.bash mod sometimes fail depending on e3 version.

NOTE: If trouble. On a recent release of e3 there's a "bug" i a makefile. The error message is something like: "module name needs to be lower case..."
Please see slack e3 channel.
Basically you need to edit the file require/configure/RULES_E3
find "module_name_check" and comment the tree rows after with "#"

The reason is that make default shell on raspi and debian is sh but on centos sh is linked to bash.
The redirection to NULL in module_name_check only works for bash.
probably e3 team will update.


## Below is not working but good to keep for reference change of raspi kernel and install sources

### Install kernel sources trial 1 NOT WORKING
```bash
#Local building
#On a Raspberry Pi, first install the latest version of Raspbian. Then boot your Pi, plug in Ethernet to give you access to the sources, and log in.
#First install Git and the build dependencies:
$sudo apt install git bc bison flex libssl-dev make
#Next get the sources, which will take some time:
$ git clone --depth=1 https://github.com/raspberrypi/linux
#Choosing sources
#Choosing sources
$sudo apt install git bc bison flex libssl-dev make
#Next get the sources, which will take some time:
$ git clone --depth=1 https://github.com/raspberrypi/linux
#Choosing sources
#The git clone command above will download the current active branch (the one we are building Raspbian images from) without any history. Omitting the --depth=1 will download the entire repository, including the full history of all branches, but this takes much longer and occupies much more storage.
#To download a different branch (again with no history), use the --branch option:
$git clone --depth=1 --branch <branch> https://github.com/raspberrypi/linux
#where <branch> is the name of the branch that you wish to downlaod.
#Refer to the original GitHub repository for information about the available branches.
```

```bash
$ sudo apt install libncurses5-dev
$ sudo apt-get update
$ sudo apt-get install linux-image-rpi-rpfv
$ apt-get install linux-headers-rpi-rpfv
$ sudo apt-get install raspberrypi-kernel-headers
```

### Install sources trial 2 seems to work!
```bash
$ git glone https://github.com/notro/rpi-source
$python rpi-source
or:
$ sudo wget https://raw.githubusercontent.com/notro/rpi-source/master/rpi-source -O /usr/local/bin/rpi-source && sudo chmod +x /usr/local/bin/rpi-source && /usr/local/bin/rpi-source -q --tag-update

# Add kernel source dir to etherlabmaster.Makefile: Need to update etherlabmaster with config option
# before: ./configure $(E3_ETHERLAB_CONF_OPTIONS) --prefix=$(E3_ETHERLAB_INSTALL_LOCATION)
# after:  ./configure $(E3_ETHERLAB_CONF_OPTIONS) --prefix=$(E3_ETHERLAB_INSTALL_LOCATION) --with-linux-dir=/usr/src/linux-headers-4.19.97-v7l+/

# Add *Raspian* in case structures etherlabmaster/scripts/*.bash
```

