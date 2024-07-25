#! /bin/bash

if [ "$START_LIGHTHOUSE_VC" = "true" ]; then
	DEFAULT_NETWORK=mainnet
	START_PARAMS=""
	MEV_BOOST_PARAMS=""
	API_PARAMS=""
	VOTING_ETH2_NODES=http://consensus:5052

	if [ "$V_FEE_RECEPIENT" != "" ]; then
		START_PARAMS="--suggested-fee-recipient=$V_FEE_RECEPIENT "
	fi

	if [ "$V_START_API" != "" ]; then
		API_PARAMS="--http --http-address 0.0.0.0 --unencrypted-http-transport "
	fi

	if [ "$ENABLE_MEV" != "" ]; then
		MEV_BOOST_PARAMS="--builder-proposals "
	fi

	# Set testnet name
	if [ "$C_NETWORK" = "" ]; then
		C_NETWORK=$DEFAULT_NETWORK
	fi

	if [ "$ENABLE_METRICS" != "" ]; then
	METRICS_PARAMS="--metrics --metrics-address 0.0.0.0 "
	fi

	if [ "$V_ENABLE_DOPPELGANGER_PROTECTION" != "" ]; then
	DOPPELGANGER_PROTECTION="--enable-doppelganger-protection "
	fi

	# Base dir
	DATADIR=/root/.lighthouse/$C_NETWORK

	WALLET_NAME=validators
	WALLET_PASSFILE=$DATADIR/secrets/$WALLET_NAME.pass


	if [ "$START_LIGHTHOUSE_VC" != "" ]; then
		if [ "$IMPORT_VALIDATORS" != "" ]; then
			echo $V_PASSPHRASE | lighthouse \
				--network $C_NETWORK \
				account validator import \
				--directory /root/validator_keys \
				--reuse-password \
				--stdin-inputs
		fi

		exec lighthouse \
			--debug-level $DEBUG_LEVEL \
			--network $C_NETWORK \
			validator \
			$MEV_BOOST_PARAMS \
			$METRICS_PARAMS \
			--beacon-nodes $VOTING_ETH2_NODES \
			$DOPPELGANGER_PROTECTION \
			$START_PARAMS \
			$API_PARAMS
	fi
fi