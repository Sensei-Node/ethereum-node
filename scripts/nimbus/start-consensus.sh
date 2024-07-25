#!/bin/bash
if [ "$START_NIMBUS_CC_VC" = "true" ]; then
	if [ "$C_CHECKPOINT_URL" != "" ]; then
		/home/user/nimbus-eth2/build/nimbus_beacon_node \
		trustedNodeSync \
		--network:${C_NETWORK} \
		--data-dir=/home/user/nimbus/data/${C_NETWORK} \
		--trusted-node-url=${C_CHECKPOINT_URL}
	fi

	FEE_RECEPIENT_PARAMS=""
	if [ "$V_FEE_RECEPIENT" != "" ]; then
		FEE_RECEPIENT_PARAMS="--suggested-fee-recipient=$V_FEE_RECEPIENT "
	fi

	MEV_PARAMS=""
	if [ "$ENABLE_MEV" != "" ]; then
			MEV_PARAMS="--payload-builder=true --payload-builder-url=$C_MEV_URL "
	fi

	if [ "$IMPORT_VALIDATORS" != "" ]; then
		echo "$V_PASSPHRASE" | /home/user/nimbus-eth2/build/nimbus_beacon_node --data-dir=/home/user/nimbus/data/${C_NETWORK} deposits import /validator-keys
	fi

	METRICS_PARAMS=""
	if [ "$ENABLE_METRICS" != "" ]; then
		METRICS_PARAMS="--metrics --metrics-address=0.0.0.0 --metrics-port=8008 "
	fi

	REST_PARAMS=""
	if [ "$ENABLE_REST_API" != "" ]; then
		REST_PARAMS="--rest --rest-address=0.0.0.0 --rest-port=${BEACON_PORT} "
	fi

	DOPPEL_PARAMS="--doppelganger-detection false "
	if [ "$V_ENABLE_DOPPELGANGER_PROTECTION" != "" ]; then
		DOPPEL_PARAMS=""
	fi

	/home/user/nimbus-eth2/build/nimbus_beacon_node \
		--network=${C_NETWORK} \
		--data-dir=/home/user/nimbus/data/${C_NETWORK} \
		--el=${C_EXECUTION_ENGINE} \
		--jwt-secret=/jwt.hex \
		--log-level=info \
		--tcp-port=9000 \
		--udp-port=9000 \
		$METRICS_PARAMS \
		$REST_PARAMS \
		$FEE_RECEPIENT_PARAMS \
		$DOPPEL_PARAMS $MEV_PARAMS \
		--history=prune \
		--graffiti=${C_GRAFFITI}
fi