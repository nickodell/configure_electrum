DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
die() { echo "$@" 1>&2 ; exit 1; }

adduser bitcoin --disabled-password
echo 1
apt-get update
apt-get install -y git make g++ python-leveldb libboost-all-dev \
                   libssl-dev libdb++-dev pkg-config python-setuptools || die

echo 2
# Fix path
echo "PATH=\"\$HOME/bin:\$PATH\"" >> ~bitcoin/.login
# If we create the file as root, the file might not be owned by bitcoin
chown bitcoin:bitcoin ~bitcoin/.login



#Copy second script to userspace
cp "$DIR/configure2.sh" ~bitcoin
chown bitcoin:bitcoin ~bitcoin/configure2.sh

echo <<ENDECHO

----------------------------
Changing to bitcoin user...
ENDECHO

su bitcoin -c "~/configure2.sh"

cd ~bitcoin/electrum-server
configure
python setup.py install
