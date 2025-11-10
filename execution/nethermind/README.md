# Nethermind Execution Client

This directory contains the Nethermind execution client configuration.

## Files

- `docker-compose.yml` - Docker Compose configuration for Nethermind
- Data directory will be created here when the service starts

## Configuration

Edit `environments/.env.execution` to configure Nethermind-specific settings.

Key environment variables:
- `E_VERSION` - Nethermind version (default: latest)
- `E_NETWORK` - Network (mainnet/goerli/sepolia/holesky)
- `BESU_OPTS` - JVM options (only applies to Besu, not Nethermind)

## Usage

Enable in `.env`:
```bash
START_NETHERMIND=true
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

Chain data is stored in `./execution/nethermind/` (mapped to `/data` in container).
