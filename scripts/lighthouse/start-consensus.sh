#! /bin/bash
#
# Starts a beacon node.

if [ "$START_LIGHTHOUSE_CC" = "true" ]; then
	DEFAULT_NETWORK=mainnet
	START_PARAMS=""
	API_PARAMS=""
	MEV_BOOST_PARAMS=""
	GRAFFITI_PARAM=""
	CHECKPOINT_SYNC_URL_PARAM=""
	SECRETS_FILE="/jwt.hex"

	if [ "$C_NETWORK" = "" ]; then
		C_NETWORK=$DEFAULT_NETWORK
	fi


	if [ ! -f "$SECRETS_FILE" ]; then
		echo "$SECRETS_FILE file does not exist"; exit $ERRCODE;
	fi
	START_PARAMS="--execution-endpoints=$C_EXECUTION_ENGINE --jwt-secrets=$SECRETS_FILE"


	if [ "$ENABLE_MEV" != "" ]; then
		if [ "$C_MEV_URL" = "" ]; then
			echo "C_MEV_URL parameter not provided and ENABLE_MEV enabled"; exit $ERRCODE;
		fi
		MEV_BOOST_PARAMS="--builder $C_MEV_URL"
	fi

	if [ "$ENABLE_METRICS" != "" ]; then
		METRICS_PARAMS="--metrics --metrics-address 0.0.0.0 "
	fi

	if [ "$C_GRAFFITI" != "" ]; then
		GRAFFITI_PARAM="--graffiti $C_GRAFFITI "
	fi

	if [ "$C_CHECKPOINT_URL" != "" ]; then
		if [ "$C_CHECKPOINT_SYNC_RECONSTRUCT" != "" ]; then
			CHECKPOINT_SYNC_URL_PARAM="--checkpoint-sync-url $C_CHECKPOINT_URL --reconstruct-historic-states "
		else
			CHECKPOINT_SYNC_URL_PARAM="--checkpoint-sync-url $C_CHECKPOINT_URL "
		fi
	fi

	if [ "$ENABLE_REST_API" = "true" ]; then
		API_PARAMS="--http --http-address 0.0.0.0 "
	fi

	exec lighthouse \
		--debug-level $DEBUG_LEVEL \
		--network $C_NETWORK \
		beacon_node \
		$API_PARAMS \
		$START_PARAMS \
		$MEV_BOOST_PARAMS \
		$METRICS_PARAMS \
		$GRAFFITI_PARAM \
		$CHECKPOINT_SYNC_URL_PARAM
fi