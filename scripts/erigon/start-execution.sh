#!/bin/bash

if [ "$START_ERIGON" = "true" ]; then
    DEFAULT_NETWORK=mainnet
    START_PARAMS=""

    if [ "$E_NETWORK" = "" ]; then
        E_NETWORK=$DEFAULT_NETWORK
    fi

    if [ "$ENABLE_INTERNAL_CONSENSUS_CLI" = "true" ]; then
        echo "Starting erigon with internal consensus cli. Sync purposes only."
        START_PARAMS="--internalcl"
    fi

    erigon \
        $START_PARAMS \
        --externalcl \
        --datadir=/data/erigon \
        --chain=${E_NETWORK} \
        --port=30303 \
        --ws --ws.port=8546 \
        --http --http.addr=0.0.0.0 --http.port=8545 \
        --http.api=eth,engine,debug,net,web3 \
        --authrpc.addr=0.0.0.0 --authrpc.port=8551 \
        --authrpc.jwtsecret=/jwt.hex
fi
      