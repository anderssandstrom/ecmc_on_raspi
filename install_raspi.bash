#!/bin/bash

install_prereqs () {
  echo "Installing vs-code....."
  wget https://packagecloud.io/headmelted/codebuilds/gpgkey -O - | sudo apt-key add -
  curl -L https://raw.githubusercontent.com/headmelted/codebuilds/master/docs/installers/apt.sh | sudo bash
  echo "can be started by: code-oss"

  echo "Installing stuff....."
  sudo apt install -y  build-essential libtool automake tree dkms

  echo "Installing hg....."
  sudo apt-get install mercurial$ sudo apt-get install mercurial

  echo "Installing kernel headers....."
  sudo apt install raspberrypi-kernel-headers

  sudo apt install tree emacs ipmitool autoconf libtool automake m4 re2c tclx coreutils graphviz build-essential libreadline-dev libxt-dev tclsh
  sudo apt install x11proto-print-dev libxmu-headers libxmu-dev libxmu6 libxpm-dev libxmuu-dev libxmuu1 libpcre++-dev libmotif-dev libsnmp-dev re2c darcs python-dev libnetcdf-dev libhdf5-dev libbz2-dev libxml2-dev libblosc-dev libtiff-dev libusb-dev libusb-1.0-0-dev libudev-dev libsystemd-dev linux-source mercurial libboost-dev libboost-regex-dev libboost-filesystem-dev libopencv-dev libpng-dev libraw1394-11 libtirpc-dev fonts-liberation logrotate curl symlinks dkms procserv

  echo "Installing python matplot lib....."
  pip install matplotlib==2.0.2
  sudo apt-get install python-gi-cairo
}

install_etherlab () {
  echo "Installing etherlab master....."
  git clone https://github.com/icshwi/etherlabmaster
  cd etherlabmaster
  echo "Overriding git tag to newer!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "EPICS_MODULE_TAG:=53ce5e56d511" > configure/CONFIG_MODULE.local

  make init
  echo "!!!!!!IMPORTANT TSC not availbe in ARM (Set ENABLE_CYCLES=NO)!!!!!!!"
  echo "ENABLE_CYCLES = NO" > configure/CONFIG_OPTIONS.local
  make build
  make install
  # probably not needed: $ make modules
  # Ensure check so files are in /opt/etherlab/ maybe "make modules" is needed?! seems sometimes "make install" fails??

  echo "ETHERCAT_MASTER0=eth0" > ethercatmaster.local

  # NOTE: add raspian to scripts/etherlab_setup.bash and script/etherlab_setup_clean.bash (in r-pi-dev branch of icshwi/etherlabmaster)

  make dkms_add
  make dkms_build
  make dkms_install
  make setup

  sudo systemctl start ethercat
  cd ..
}

install_epics_base () {
  echo "Installing  Epics E3 7 base and require....."
  git clone https://gitlab.esss.lu.se/e3/e3 e3-7.0.4
  cd e3-7.0.4
  ./e3_building_config.bash -r3.3.0 -t${HOME}/epics setup
  bash e3.bash base
  bash e3.bash req
  cd ..
}

install_epics_mods () {
  echo "Installing Epics E3 ethercat modules....."  
  cd e3-7.0.4
  bash e3.bash -ce mod
  bash e3.bash -ce load
  cd ..
}

################### MAIN ##################################

if [ $1 == "all" ]; then
    echo "INSTALL ALL!!"
    install_prereqs
    install_etherlab
    install_epics_base
    install_epics_mods
    exit 0
fi

### No args
while true; do
    echo ""
    read -p "Do you wish to install prereqs (y/n)?" yn
    case $yn in
        [Yy]* ) install_prereqs; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    echo ""
    read -p "Do you wish to install etherlab (y/n)?" yn
    case $yn in
        [Yy]* ) install_etherlab; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    echo ""
    read -p "Do you wish to install E3 (epics base and require) (y/n)?" yn
    case $yn in
        [Yy]* ) install_epics_base; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    echo ""
    read -p "Do you wish to install E3 ethercat and motion modules (y/n)?" yn
    case $yn in
        [Yy]* ) install_epics_mods; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
