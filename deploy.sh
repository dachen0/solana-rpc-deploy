#!/bin/bash

# args: $AGAVE_VERSION
no_rpc="n"
if [ "$#" -ne 1 ]; then
    echo "Not enough params: run this script with the following args: AGAVE_VERSION"
    echo "If you only want to install non rpc components, enter y:"
    read no_rpc
    if [ "$no_rpc" != "y" ]; then
        exit 1
    fi
fi

rpc_x_token=$(cat /proc/sys/kernel/random/uuid)
starting_pwd=$(pwd)

# updates
sudo apt-get update
sudo apt-get upgrade -y

# solana user
sudo useradd -M solana
sudo usermod -L solana

# setup service
sudo cp solana-validator.service /etc/systemd/system/solana-validator.service
sudo systemctl enable solana-validator.service
sudo systemctl stop solana-validator.service

# get requirements to build agave validator
curl https://sh.rustup.rs -sSf | sh
source $HOME/.cargo/env
rustup update
sudo apt-get install -y libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang cmake make libprotobuf-dev protobuf-compiler libclang-dev

# clone validator
sudo mkdir /solana
cd /solana
git clone https://github.com/anza-xyz/agave

# install solana cli tools
sh -c "$(curl -sSfL https://release.anza.xyz/v4.4.0-beta.1/install)"
PATH="/root/.local/share/solana/install/active_release/bin:$PATH"

# generate validator identity
solana-keygen new -o /solana/unstaked_validator_identity.json
ln -sf /solana/unstaked_validator_identity.json /solana/validator_identity.json

cd $starting_pwd
if [ "$no_rpc" != "y" ]; then
    # setup nginx
    sudo apt-get install nginx
    # probably not the best way but it works!
    sudo cp nginx-reverse-proxy /etc/nginx/sites-enabled/default

    # build validator and yellowstone plugin
    bash build-validator.sh $1
else
    # just build validator
    bash build-validator.sh $1
fi


# tune knobs or whatever
sudo cp sysctl.conf /etc/sysctl.d/21-solana-validator.conf
sudo sysctl -p /etc/sysctl.d/21-solana-validator.conf

# logrotate
sudo cp logrotate /etc/logrotate.d/sol
systemctl restart logrotate.service

# move validator start script
cp start_validator.sh /solana/start_validator.sh
chmod +x /solana/start_validator.sh

# transfer ownership of /solana directory to the solana user
chown -R solana /solana
chown -R $(whoami) /solana/agave
chmod -R +r /solana/agave

# start rpc
sudo systemctl start solana-validator.service

# echo the variables
if [ "$no_rpc" != "y" ]; then
    echo RPC is deloyed at http://0.0.0.0:8899/$rpc_x_token
else
    echo Validator deployed! Don\'t forget to change the start_validator params and copy keys.
fi
