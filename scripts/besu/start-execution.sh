#!/bin/bash
if [ "$START_BESU" = "true" ]; then
    DEFAULT_NETWORK=mainnet
    START_PARAMS=""

    if [ "$E_NETWORK" = "" ]; then
        E_NETWORK=$DEFAULT_NETWORK
    fi

    if [ "$ENABLE_REST_API" = "true" ]; then
        START_PARAMS="--rpc-http-enabled=true \
        --rpc-http-host=0.0.0.0 \
        --engine-rpc-enabled=true \
        --engine-jwt-secret=/jwt.hex \
        --rpc-http-api=WEB3,ETH,NET \
        --engine-host-allowlist=* \
        --host-allowlist=*"
    fi

    besu \
        --data-storage-format=BONSAI \
        --network=${E_NETWORK} \
        --sync-mode=X_CHECKPOINT \
        $START_PARAMS \
        --data-path=/var/lib/besu/data
fi