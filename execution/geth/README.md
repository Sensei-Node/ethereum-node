# Geth Execution Client

This directory contains the Geth (Go Ethereum) execution client configuration.

## Files

- `docker-compose.yml` - Docker Compose configuration for Geth
- `docker-compose.clef.yml` - Clef signer for secure transaction signing
- `clef/rules.js` - Clef rules for automatic signing
- Data directory will be created here when the service starts

## Configuration

Edit `environments/.env.execution` to configure Geth-specific settings.

Key environment variables:
- `E_VERSION` - Geth version (default: latest)
- `E_NETWORK` - Network (mainnet/goerli/sepolia/holesky)
- `E_PRIVATE_NETWORK` - Enable private network support (true/false)
- `E_NETWORK_ID` - Network ID for private networks
- `E_MINER_ADDRESS` - Etherbase miner address for block signing

## Usage

Enable in `.env`:
```bash
START_GETH=true
```

For Clef signer (private networks):
```bash
START_CLEF=true
```

Then run:
```bash
./node.sh
```

## Ports

- 30303/tcp, 30303/udp - P2P
- 8545 - JSON-RPC API
- 8551 - Engine API (authenticated with JWT)

## Data Location

Chain data is stored in `./execution/geth/` (mapped to `/root/.ethereum` in container).

## Clef Setup

For private networks using Clef, see the main README for initialization steps.
