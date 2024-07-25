#!/bin/bash

echo $JWT_SECRET > /scripts/.jwt
openexecution \
    --db-host $DB_HOST \
    --db-name $POSTGRES_DB \
    --db-pass $POSTGRES_PASSWORD \
    --db-port $POSTGRES_PORT \
    --db-user $POSTGRES_USER \
    --jwt-secret /scripts/.jwt \
    --listen-addr $LISTEN_ADDR \
    --log-level $LOG_LEVEL \
    --node $EXECUTION_API_ETH_NODE \
    --port $LISTEN_PORT \
    --unauth-node $INSECURE_ETH_NODE