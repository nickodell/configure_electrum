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
cp "$DIR/configure2.sh" ~bitcoin
chown bitcoin:bitcoin ~bitcoin/configure2.sh

echo <<ENDECHO

----------------------------
Changing to bitcoin user...
ENDECHO

su bitcoin -c "~/configure2.sh"

cd ~bitcoin/electrum-server

apt-get install -y python-setuptools python-openssl python-leveldb \
           libleveldb-dev || die
easy_install jsonrpclib irc plyvel || die

configure || die
python setup.py install || die
