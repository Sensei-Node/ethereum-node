# Lighthouse Consensus Client

This directory contains the Lighthouse consensus and validator client configurations.

## Files

- `docker-compose.yml` - Lighthouse beacon node (consensus client)
- `docker-compose.validator.yml` - Lighthouse validator client
- Data directory will be created here when the service starts

## Configuration

Edit `environments/.env.consensus` for beacon node settings and `environments/.env.validator` for validator settings.

Key environment variables:
- `C_VERSION` - Lighthouse version (default: latest)
- `C_NETWORK` - Network (mainnet/goerli/sepolia/holesky)
- `C_CHECKPOINT_URL` - Checkpoint sync URL for fast sync
- `ENABLE_MEV` - Enable MEV-Boost integration
- `C_MEV_URL` - MEV-Boost endpoint

## Usage

**Beacon Node Only (RPC):**
```bash
START_LIGHTHOUSE_CC=true
```

**Beacon + Validator:**
```bash
START_LIGHTHOUSE_CC=true
START_LIGHTHOUSE_VC=true
```

Then run:
```bash
./node.sh
```

## Validator Setup

1. Place your validator keystores in `../../keystores/lighthouse/`
2. Configure password in `environments/.env.validator`:
   ```bash
   V_PASSPHRASE='your-keystore-password'
   V_FEE_RECIPIENT=0xYourAddress
   ```
3. Start services

## Ports

- 9000/tcp, 9000/udp - P2P
- 5052 - Beacon API

## Data Location

- Beacon data: `./consensus/lighthouse/` (mapped to `/root/.lighthouse` in container)
- Validator keys: `../../keystores/lighthouse/` (read-only)

## Checkpoint Sync

For fast sync, configure in `environments/.env.consensus`:
```bash
C_CHECKPOINT_URL=https://sync.invis.tools/
```

More endpoints: https://eth-clients.github.io/checkpoint-sync-endpoints
