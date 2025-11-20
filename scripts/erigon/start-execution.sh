#!/bin/bash

if [ "$START_ERIGON" = "true" ]; then
    DEFAULT_NETWORK=mainnet
    START_PARAMS="--externalcl "

    if [ "$E_NETWORK" = "" ]; then
        E_NETWORK=$DEFAULT_NETWORK
    fi

    if [ "$ENABLE_INTERNAL_CONSENSUS_CLI" = "true" ]; then
        echo "Starting erigon with internal consensus cli. Sync purposes only."
        START_PARAMS="--caplin.enable-upnp \
        --caplin.discovery.addr=0.0.0.0 \
        --caplin.discovery.port=4000 \
        --caplin.discovery.tcpport=4001 \
        --beacon.api.port=5052 \
        --beacon.api=beacon,validator,builder,config,debug,events,node,lighthouse \
        "
    fi

    erigon \
        $START_PARAMS \
        --datadir=/data/erigon \
        --chain=${E_NETWORK} \
        --port=30303 \
        --ws --ws.port=8546 \
        --http --http.addr=0.0.0.0 --http.port=8545 \
        --http.api=eth,engine,debug,net,web3 \
        --authrpc.addr=0.0.0.0 --authrpc.port=8551 \
        --authrpc.jwtsecret=/jwt.hex
fi
      