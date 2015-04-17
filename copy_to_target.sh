#!/bin/bash
git add .
git commit -m "Automatically generated commit"
git push
ssh "$@" "rm -rf /root/configure_electrum; \
          apt-get install -y git && \
          git clone https://github.com/nickodell/configure_electrum && \
          ./configure_electrum/configure.sh"
