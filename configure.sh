DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
die() { echo "$@" 1>&2 ; exit 1; }

adduser bitcoin --disabled-password || die
echo 1
apt-get install -y git make g++ python-leveldb libboost-all-dev \
                   libssl-dev libdb++-dev pkg-config || die
echo 2
# Fix path
echo "PATH=\"\$HOME/bin:\$PATH\"" >> ~bitcoin/.login
# If we create the file as root, the file might not be owned by bitcoin
chown bitcoin:bitcoin ~bitcoin/.login


echo <<ENDECHO

----------------------------
Changing to bitcoin user...
ENDECHO

su bitcoin -c "$DIR/configure2.sh"

cd ~bitcoin/electrum-server
configure
python setup.py install
