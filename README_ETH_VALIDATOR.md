# Ethereum mainnet validator node

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

Only make the deposit once you are completely sure that you've properly specified the proper withdrawal address and you have stored the mnemonic/keystores and its passphrases.