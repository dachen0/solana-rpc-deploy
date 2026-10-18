#!/bin/bash
cd /solana/agave
git pull
git checkout $1
./scripts/cargo-install-all.sh . --release-with-lto