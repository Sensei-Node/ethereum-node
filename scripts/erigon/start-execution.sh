#!/bin/bash

if [ "$START_ERIGON" = "true" ]; then
    START_PARAMS=""

    if [ "$ENABLE_INTERNAL_CONSENSUS_CLI" = "true" ]; then
        echo "Starting erigon with internal consensus cli. Sync purposes only."
		START_PARAMS="--internalcl"
	fi

    erigon \
        $START_PARAMS --prune=hrtc \
        --datadir=/home/erigon/.local/share/erigon \
        --chain=mainnet --port=30303 --ws \
        --http --http.addr=0.0.0.0 --http.port=8545 \
        --http.api=eth,engine,debug,net,web3,erigon \
        --authrpc.addr=0.0.0.0 --authrpc.port=8551 \
        --authrpc.jwtsecret=/jwt.hex \
        --private.api.addr=0.0.0.0:9090 
fi
      