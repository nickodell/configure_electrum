#!/bin/bash
ssh "$@" "apt-get install -y git && \
          git clone https://github.com/nickodell/configure_electrum && \
          ./configure_electrum/configure.sh"
