#!/bin/sh
#
# Starts a local fast-synced geth node.

if [ "$START_GETH" = "true" ]; then
	DEFAULT_FLAGS="--ipcdisable"
	DEFAULT_NETWORK=mainnet
	SECRETS_FILE="/jwt.hex"
	START_PARAMS=""
	NETWORK_PARAMS=""

	if [ ! -f "$SECRETS_FILE" ]; then
		echo "$SECRETS_FILE file does not exist"; exit $ERRCODE;
	fi

	if [ "$E_NETWORK" = "" ]; then
		E_NETWORK=$DEFAULT_NETWORK
	fi

	if [ "$ENABLE_REST_API" = "true" ]; then
		START_PARAMS="--authrpc.addr=0.0.0.0 \
		--authrpc.port=8551 \
		--authrpc.vhosts=* \
		--http.api=engine,eth,web3,net,debug \
		--authrpc.jwtsecret=$SECRETS_FILE \
		--http.vhosts=* --http.corsdomain=* \
		--http --http.addr=0.0.0.0"
	fi

	if [ "$E_NETWORK" = "sepolia" ]; then
		NETWORK_PARAMS="--sepolia"
	fi

	if [ "$E_NETWORK" = "hoodi" ]; then
		NETWORK_PARAMS="--hoodi"
	fi

	if [ "$E_PRIVATE_NETWORK" = "true" ]; then
		echo "Starting gETH with custom private network"
		NETWORK_PARAMS="--networkid $E_NETWORK_ID"
		START_PARAMS="$START_PARAMS --datadir /root/.ethereum/ --config /root/.ethereum/config.toml"
		DEFAULT_FLAGS=""
		if [ "$START_CLEF" = "true" ]; then
			DEFAULT_FLAGS="--mine --miner.etherbase $E_MINER_ADDRESS --signer /root/.ethereum/clef/clef.ipc"
		fi
		geth init --datadir /root/.ethereum/ /root/.ethereum/genesis.json
	fi
	exec geth $NETWORK_PARAMS $START_PARAMS $DEFAULT_FLAGS
fi