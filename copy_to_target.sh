#!/bin/bash
# Copies this repository to the remote system, then starts the config script
# there.
# Usage: ./copy_to_target.sh root@[worker-ip]

git add .
git commit -m "Automatically generated commit"
git push
ssh "$@" "rm -rf /root/configure_electrum; \
          apt-get install -y git && \
          git clone https://github.com/nickodell/configure_electrum && \
          nohup ./configure_electrum/configure.sh"
