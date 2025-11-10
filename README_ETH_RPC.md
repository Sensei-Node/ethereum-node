# Ethereum Mainnet RPC Node

This guide shows you how to launch an Ethereum mainnet RPC node using Lighthouse (consensus client) and Nethermind (execution client).

## Prerequisites

- Docker with Compose
- Linux or macOS
- Minimum 2TB disk space for mainnet
- 16GB+ RAM recommended

See the main [README.md](README.md) for detailed installation instructions.

## Quick Setup

### 1. Clone the repository

```bash
git clone https://github.com/Sensei-Node/ethereum-node.git && cd ethereum-node
```

### 2. Configure environment

```bash
# Copy the default configuration
cp default.env .env

# Copy service-specific environment files
cp environments/default.env.execution environments/.env.execution
cp environments/default.env.consensus environments/.env.consensus
```

### 3. Enable required services

Edit `.env` and enable Nethermind and Lighthouse:

```bash
# Execution client
START_NETHERMIND=true

# Consensus client
START_LIGHTHOUSE_CC=true

# All other services should be false
```

### 4. Configure checkpoint sync (recommended)

For faster initial sync, edit `environments/.env.consensus`:

```bash
C_CHECKPOINT_URL=https://sync.invis.tools/
```

### 5. Start the node

```bash
./node.sh
```

The JWT secret will be automatically generated on first run.

## Managing Your Node

### View logs

```bash
# All services
./node.sh logs

# Specific service
./node.sh logs execution
./node.sh logs consensus
```

### Check status

```bash
./node.sh status
```

### Stop the node

```bash
./node.sh stop
```

### Restart the node

```bash
./node.sh restart
```

## Monitoring Sync Progress

### Check execution client sync status

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545
```

Returns sync status object or `false` when fully synced.

### Check consensus client sync status

```bash
curl http://localhost:5052/eth/v1/node/syncing
```

Shows beacon node sync progress.

### Monitor logs in real-time

```bash
./node.sh logs execution
./node.sh logs consensus
```

## What's Next?

### Add Validator Capabilities

To run validators on this node, see [README_ETH_VALIDATOR.md](README_ETH_VALIDATOR.md)

### Exposed Endpoints

Once synced, your node exposes:
- **Execution RPC**: http://localhost:8545
- **Beacon API**: http://localhost:5052

### Alternative Clients

You can use different client combinations by editing `.env`:

**Execution clients:**
- `START_NETHERMIND=true` (recommended for RPC)
- `START_GETH=true`
- `START_BESU=true`
- `START_RETH=true`
- `START_ERIGON=true` (best for archive nodes)

**Consensus clients:**
- `START_LIGHTHOUSE_CC=true` (recommended)
- `START_NIMBUS_CC_VC=true`

See [EXAMPLES.md](EXAMPLES.md) for more configuration options.

## API Documentation

- [Beacon Node API](https://ethereum.github.io/beacon-APIs/)
- [JSON-RPC Execution API](https://ethereum.org/en/developers/docs/apis/json-rpc/)

## Troubleshooting

### Node not syncing

Check that checkpoint sync is configured in `environments/.env.consensus`:
```bash
C_CHECKPOINT_URL=https://sync.invis.tools/
```

### Port already in use

Ensure no other Ethereum clients are running on ports 8545, 8551, 5052, 9000, or 30303.

### Disk space issues

Monitor disk usage:
```bash
du -sh execution/nethermind/
du -sh consensus/lighthouse/
```

Mainnet requires ~2TB for full node.