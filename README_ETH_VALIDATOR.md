# Ethereum Validator Node

This guide shows you how to add validator capabilities to your Ethereum node. You should have already set up an RPC node following [README_ETH_RPC.md](README_ETH_RPC.md).

## Prerequisites

- Running Ethereum execution + consensus client (see [README_ETH_RPC.md](README_ETH_RPC.md))
- 32+ ETH per validator you want to run
- Validator keystores (generated in next step)

## Step 1: Generate Validator Keystores

Use the official [Ethereum Staking Deposit CLI](https://github.com/ethereum/staking-deposit-cli) to create validator keys.

### Download the CLI

Download the latest release for your platform from the [releases page](https://github.com/ethereum/staking-deposit-cli/releases).

### Generate Keys with Withdrawal Address

**Important:** The withdrawal address is where your staked ETH will be sent. This cannot be changed later!

```bash
cd staking-deposit-cli

# Replace ADDRESS with your Ethereum withdrawal address
./deposit new-mnemonic --execution_address=ADDRESS
```

Follow the prompts:
1. Choose mnemonic language
2. Enter number of validators to create
3. Set a strong keystore passphrase
4. Select network (mainnet/sepolia)

**Save your mnemonic securely!** You'll need it to recover your validator keys.

## Step 2: Import Keystores

Copy the generated keystores to the appropriate directory for your validator client.

### For Lighthouse Validator

```bash
# Generated keystores are in staking-deposit-cli/validator_keys/
cp staking-deposit-cli/validator_keys/keystore-m_*.json keystores/lighthouse/
```

### For Nimbus Validator

```bash
cp staking-deposit-cli/validator_keys/keystore-m_*.json keystores/nimbus/
```

## Step 3: Configure Validator

### Enable validator service

Edit `.env`:

```bash
# For Lighthouse validator (if using Lighthouse consensus)
START_LIGHTHOUSE_VC=true

# For Nimbus (already includes validator)
START_NIMBUS_CC_VC=true
```

### Configure validator settings

```bash
# Copy the template
cp environments/default.env.validator environments/.env.validator

# Edit the file
nano environments/.env.validator
```

Set these important values:

```bash
# Fee recipient - where you receive transaction tips (YOUR address)
V_FEE_RECIPIENT=0xYourEthereumAddress

# Keystore passphrase - what you set during key generation
V_PASSPHRASE='your-keystore-passphrase'

# Suggested fee recipient (same as above)
V_SUGGESTED_FEE_RECIPIENT=0xYourEthereumAddress
```

**Security note:** If your passphrase contains special characters, use single quotes.

## Step 4: Make Validator Deposits

Before starting your validator, deposit 32 ETH for each validator using the Ethereum Launchpad:

- **Mainnet:** https://launchpad.ethereum.org/
- **Sepolia Testnet:** https://sepolia.launchpad.ethereum.org/

**⚠️ Critical:** Only deposit after:
1. You've securely backed up your mnemonic
2. You've verified the withdrawal address is correct
3. Your node is fully synced
4. You've tested with the testnet first

## Step 5: Start the Validator

```bash
./node.sh restart
```

This will restart your node with the validator enabled.

## Step 6: Monitor Your Validator

### Check validator logs

```bash
./node.sh logs validator
```

### Check validator status

```bash
# Using beacon API
curl http://localhost:5052/eth/v1/beacon/states/head/validators
```

### Track your validator

Use these tools to monitor your validator's performance:
- **Beaconcha.in:** https://beaconcha.in/ (enter your validator pubkey)
- **Rated Network:** https://www.rated.network/

## Validator Exits (Withdrawals)

When you want to stop validating and withdraw your ETH, you must perform a **voluntary exit**.

### Important Notes

- Voluntary exits are **irreversible**
- You cannot re-activate an exited validator
- Withdrawals take time to process (several days)
- Keep your validator running until the exit epoch

### Exit Process for Lighthouse

```bash
docker exec -it consensus lighthouse \
  --network mainnet \
  account validator exit \
  --keystore /root/validator_keys/keystore-m_XXXXX.json \
  --beacon-node http://localhost:5052
```

For Sepolia testnet, replace `mainnet` with `sepolia`.

### You'll be prompted for:

1. **Keystore passphrase** - Enter the passphrase you used when creating the keystore
2. **Exit confirmation** - Type exactly: `Exit my validator`

### Example Output

```bash
Running account manager for mainnet network
validator-dir path: ~/.lighthouse/mainnet/validators

Enter the keystore password for validator in 0xabcd...

Password is correct

Publishing a voluntary exit for validator 0xabcd...

WARNING: THIS IS AN IRREVERSIBLE OPERATION

PLEASE VISIT https://lighthouse-book.sigmaprime.io/voluntary-exit.html
TO MAKE SURE YOU UNDERSTAND THE IMPLICATIONS OF A VOLUNTARY EXIT.

Enter the exit phrase from the above URL to confirm the voluntary exit:
Exit my validator

Successfully published voluntary exit for validator 0xabcd...
Voluntary exit has been accepted into the beacon chain, but not yet finalized.
Current epoch: 29946, Exit epoch: 29951, Withdrawable epoch: 30207
Please keep your validator running till exit epoch
Exit epoch in approximately 1920 secs
```

### After Exit

Your ETH will be automatically withdrawn to the withdrawal address you specified when creating the validator keys. This happens in two phases:

1. **Exit epoch:** When your validator stops validating (~27 hours after exit)
2. **Withdrawable epoch:** When your balance becomes withdrawable

## MEV-Boost (Optional but Recommended)

To maximize validator rewards, you can enable MEV-Boost.

### Enable MEV-Boost

Edit `.env`:
```bash
START_MEV_BOOST=true
```

Configure relays in `environments/.env.mev`:
```bash
MEV_RELAYS=-mainnet \
  -relay https://0xac6e77dfe25ecd6110b8e780608cce0dab71fdd5ebea22a16c0205200f2f8e2e3ad3b71d3499c54ad14d6c21b41a37ae@boost-relay.flashbots.net \
  -relay https://0xa7ab7a996c8584251c8f925da3170bdfd6ebc75d50f5ddc4050a6fdc77f2a3b5fce2cc750d0865e05d7228af97d69561@agnostic-relay.net
```

Enable in `environments/.env.consensus`:
```bash
ENABLE_MEV=true
C_MEV_URL=http://mev-boost:18550
```

Restart your node:
```bash
./node.sh restart
```

## Best Practices

### Security
- Never share your mnemonic or keystores
- Use strong, unique passphrases
- Keep backups in multiple secure locations
- Consider hardware wallets for withdrawal addresses

### Monitoring
- Check logs daily: `./node.sh logs validator`
- Monitor attestation performance on beaconcha.in
- Set up alerts for missed attestations
- Keep your system updated

### Maintenance
- Ensure >99% uptime for optimal rewards
- Keep adequate disk space (monitor with `df -h`)
- Update clients regularly (check `.env` for versions)
- Have a backup power supply

### Testing
- Always test on Sepolia testnet first
- Verify your setup for at least a week on testnet
- Practice exits on testnet before mainnet

## Troubleshooting

### Validator not attesting

Check that:
1. Consensus client is fully synced: `curl http://localhost:5052/eth/v1/node/syncing`
2. Execution client is synced: `curl -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'`
3. Keystores are in the correct directory
4. Passphrase is correct in `.env.validator`

### Invalid keystore passphrase

Ensure special characters in passphrase are properly quoted in `environments/.env.validator`:
```bash
V_PASSPHRASE='p@ssw0rd$123!'  # Use single quotes
```

### Slashing risks

To avoid slashing:
- Never run the same validator keys on multiple machines
- Always properly exit validators before moving them
- Keep system time synchronized (NTP)
- Don't import the same keys to multiple validator clients

## Additional Resources

- [Ethereum Staking Guide](https://ethereum.org/en/staking/)
- [Lighthouse Book](https://lighthouse-book.sigmaprime.io/)
- [Nimbus Guide](https://nimbus.guide/)
- [MEV-Boost Documentation](https://boost.flashbots.net/)

For more configuration examples, see [EXAMPLES.md](EXAMPLES.md).