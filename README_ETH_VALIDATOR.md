# Ethereum validator node

This is a continuation of [README_ETH_RPC.md](README_ETH_RPC.md). In order to also start lighthouse validator client you should follow the next steps.

## Generate keystore files

The recommended way of generating validator keystore files is via the [official cli](https://github.com/ethereum/staking-deposit-cli). Download the latest binaries for your current distribution (linux/darwin/windows) from the [release page](https://github.com/ethereum/staking-deposit-cli/releases).
We will show here how to create validator keystores with a new mnemonic and specifying the withdrawal address with `--execution_address` flag. You should the follow the steps that will appear during the setup (mnemonic language, amount of validators to create, passphrase to use for keystores and network).

```bash
cd staking-deposit-cli
# important: replace ADDRESS with your withdrawal address, your deposited eth will be withdrawn to this address
./deposit new-mnemonic --execution_address=ADDRESS
```

## Copy generated keystores to validator client

Generated keystores will appear inside `staking-deposit-cli/validator_keys` folder. You should copy all the keystore files that look like `keystore-m_*.json` to the corresponding validator client used (ie. if you started lighthouse validator client keys should be palce inside `keystores/lighthouse`).

## Prepare the environment files

In the `.env` file leave all variables the same, and set the following variables to true:

```bash
START_LIGHTHOUSE_VC=true
```

Copy the template environment file for validator inside environments folder:

```bash
cp environments/default.env.validator environments/.env.validator
```

After that specify its values accordingly. Mainly you should set `V_FEE_RECEPIENT` to an ethereum address you manage, this is where you will receive tips rewards. And also `V_PASSPHRASE` should use the passphrase you specified during [keystore creation step](#generate-keystore-files)

## Deposit the validator/s

You should fund your validator/s with 32 eth each. For doing this you could use ethereum launchpad ([mainnet](https://launchpad.ethereum.org/en/)/[holesky](https://holesky.launchpad.ethereum.org/)). It is self explanatory, and also helps you with the validator keys generation step if this guide was not clear enough. 

**Only make the deposit once you are completely sure that you've properly specified the proper withdrawal address and you have stored the mnemonic/keystores and its passphrases.**

# Validator exits

Once you are done with your validator (you want to withdraw your funds) you need to perform a called [voluntary exit](https://lighthouse-book.sigmaprime.io/voluntary-exit.html).

If you have setup your validator using this guide, you can do the voluntary exit for each validator by following the next steps:

```bash

docker exec -it consensus lighthouse --network holesky account validator exit --keystore /root/validator_keys/keystore-XXX.json --beacon-node http://consensus:5052

```

Having executed this command properly will prompt you for a few things:

1. Keystore passphrase
2. Acknowledge to perform the exit: just writing "Exit my validator"

```bash
Running account manager for Holesky network
validator-dir path: ~/.lighthouse/holesky/validators

Enter the keystore password for validator in 0xabcd

Password is correct

Publishing a voluntary exit for validator 0xabcd

WARNING: WARNING: THIS IS AN IRREVERSIBLE OPERATION



PLEASE VISIT https://lighthouse-book.sigmaprime.io/voluntary-exit.html
TO MAKE SURE YOU UNDERSTAND THE IMPLICATIONS OF A VOLUNTARY EXIT.

Enter the exit phrase from the above URL to confirm the voluntary exit:
Exit my validator

Successfully published voluntary exit for validator 0xabcd
Voluntary exit has been accepted into the beacon chain, but not yet finalized. Finalization may take several minutes or longer. Before finalization there is a low probability that the exit may be reverted.
Current epoch: 29946, Exit epoch: 29951, Withdrawable epoch: 30207
Please keep your validator running till exit epoch
Exit epoch in approximately 1920 secs
```

Note: in this case **lighthouse** consensus/validator client, **holesky** network and **keystore-XXX.json** keystore file name were used for running the validator. In case you have different specs, modify them accordingly.