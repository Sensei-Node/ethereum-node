#!/bin/bash
if [ "$START_MEV_BOOST" = "true" ]; then
    /app/mev-boost \
    --addr=0.0.0.0:18550 \
    --${MEV_NETWORK} \
    --relay-check \
    --relays=${MEV_RELAYS}
fi