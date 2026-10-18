#!/bin/bash
cd /solana/agave
git pull
git checkout $1
./scripts/cargo-install-all.sh . --release-with-lto
sudo setcap cap_net_raw,cap_net_admin,cap_bpf,cap_perfmon=p ./bin/agave-validator