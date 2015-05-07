#!/bin/bash
# Nick O'Dell
# Sets up worker node. Run by ./copy_to_target.sh

# It does these major things:
#Installs dependencies
#Downloads Bitcoin source
#Makes a bitcoin user to run the Bitcoin client.
#Steps down into bitcoin, and runs configure-userspace.sh
#Makes an electrum user to run the electrum client
#Installs Electrum
#Configures crontabs for electrum

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
die() { echo "$@" 1>&2 ; exit 1; }

adduser bitcoin --disabled-password
apt-get update
apt-get install -y git make g++ python-leveldb libboost-all-dev \
                   libssl-dev libdb++-dev pkg-config || die

# Fix path
echo "PATH=\"~/bin:\$PATH\"" >> /etc/bash.bashrc
# If we create the file as root, the file might not be owned by bitcoin
chown bitcoin:bitcoin ~bitcoin/.login



#Copy second script to home
cp "$DIR/configure-userspace.sh" ~bitcoin
chown bitcoin:bitcoin ~bitcoin/configure-userspace.sh

echo <<ENDECHO

----------------------------
Changing to bitcoin user...
ENDECHO

su bitcoin -c "~/configure-userspace.sh"

cd ~bitcoin/electrum-server

apt-get install -y python-setuptools python-openssl python-leveldb \
                   libleveldb-dev || die
easy_install jsonrpclib irc plyvel || die

echo
echo "Running ./configure"
# Patch configure
sed -i "s/read -p \"Do you want to download it from the Electrum.*/REPLY=Y/" configure
./configure || die

echo
echo "Running setup.py"
python setup.py install || die

# Set it up
adduser electrum --disabled-password
chown electrum:electrum /var/log/electrum.log
su electrum -c "crontab -l | { cat; echo \"0 * * * * electrum-server start\"; } | crontab -"
su electrum -c "crontab -l | { cat; echo \"@reboot electrum-server start\"; } | crontab -"
