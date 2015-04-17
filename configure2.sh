# To be run as the bitcoin user
die() { echo "$@" 1>&2 ; exit 1; }


mkdir ~/bin ~/src
echo "\$PATH=$PATH"

echo <<ENDECHO

--------------------------------------------
Downloading Bitcoin
ENDECHO

cd ~/src || die
wget https://bitcoin.org/bin/0.10.0/bitcoin-0.10.0.tar.gz || die
sha256sum bitcoin-0.10.0.tar.gz | grep -c a516cf6d9f58a117607148405334b35d3178df1ba1c59229609d2bcd08d30624 || die "Bad tarfile"
tar xfz bitcoin-0.10.0.tar.gz || die
cd bitcoin-0.10.0 || die
./configure --disable-wallet --without-miniupnpc || die
make || die
strip src/bitcoind src/bitcoin-cli src/bitcoin-tx || die
cp -a src/bitcoind src/bitcoin-cli src/bitcoin-tx ~/bin || die

cd ~
mkdir .bitcoin
cd .bitcoin
PASSWORD="$RANDOM-$RANDOM-$RANDOM-$RANDOM"
cat <<ENDCONF > bitcoin.conf
rpcuser=rpcuser
rpcpassword=$PASSWORD
daemon=1
txindex=1
ENDCONF

# Start bitcoind
bitcoind

echo <<ENDECHO

---------------
Waiting for syncronization...
ENDECHO
LOCAL="`bitcoin-cli getblockcount`"
wget https://blockchain.info/q/getblockcount`" -q -O remote_count

until grep -c "^$LOCAL$" remote_count
do
  echo "Local block count: $LOCAL"
  echo -n "BC.info block count: "
  cat remote_count
  LOCAL="`bitcoin-cli getblockcount`"
  wget https://blockchain.info/q/getblockcount`" -q -O remote_count
  sleep 60
done

echo <<ENDECHO

--------------
Downloading electrum...
ENDECHO

cd ~
git clone https://github.com/spesmilo/electrum-server.git


echo <<ENDECHO

----------------
Changing back to root
ENDECHO
