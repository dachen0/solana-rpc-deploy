#!/bin/bash

exec /solana/agave/target/release/agave-validator\
        --no-voting\
        --identity /solana/validator_identity.json\
        --accounts /solana/accounts\
        --ledger /solana/ledger\
        --limit-ledger-size 50000000\
        --entrypoint entrypoint.mainnet-beta.solana.com:8001\
        --entrypoint entrypoint2.mainnet-beta.solana.com:8001\
        --entrypoint entrypoint3.mainnet-beta.solana.com:8001\
        --entrypoint entrypoint4.mainnet-beta.solana.com:8001\
        --entrypoint entrypoint5.mainnet-beta.solana.com:8001\
        --rpc-port 1100\
        --no-port-check\
        --account-index spl-token-owner\
        --account-index program-id\
        --log /solana/solana-validator.log\
        --snapshots /solana/snapshots\
        --full-rpc-api\
        --private-rpc\
        --account-index-exclude-key kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6