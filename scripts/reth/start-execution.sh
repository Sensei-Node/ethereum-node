#!/bin/bash

if [ "$START_RETH" = "true" ]; then
    START_PARAMS=""

    if [ "$ENABLE_REST_API" = "true" ]; then
		START_PARAMS="--authrpc.addr 0.0.0.0 \
        --authrpc.port 8551 \
        --authrpc.jwtsecret /jwt.hex \
        --http --http.addr 0.0.0.0 --http.port 8545 \
        --http.api=eth,net,web3"
	fi

    /usr/local/bin/reth node \
        --full \
        --chain ${E_NETWORK} \
        --metrics 0.0.0.0:9001 \
        $START_PARAMS \
        --log.file.directory /root/rethlogs
fi
