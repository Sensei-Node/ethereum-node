#!/bin/bash

if [ "$START_NETHERMIND" = "true" ]; then
    DEFAULT_NETWORK=mainnet
    START_PARAMS=""

    if [ "$E_NETWORK" = "" ]; then
        E_NETWORK=$DEFAULT_NETWORK
    fi
    
    if [ "$ENABLE_REST_API" = "true" ]; then
        START_PARAMS="--JsonRpc.Enabled=true \
        --JsonRpc.Host=0.0.0.0 \
        --JsonRpc.Port=8545 \
        --JsonRpc.EnabledModules=[Web3,Eth,Subscribe,Net,Health] \
        --JsonRpc.JwtSecretFile=/jwt.hex \
        --JsonRpc.EngineHost=0.0.0.0 \
        --JsonRpc.EnginePort=8551"
    fi

    /nethermind/nethermind \
        --config=${E_NETWORK} \
        --datadir=/data \
        --log=INFO \
        --Sync.SnapSync=true \
        $START_PARAMS \
        --Network.DiscoveryPort=30303 \
        --HealthChecks.Enabled=true \
        --Pruning.CacheMb=2048
fi