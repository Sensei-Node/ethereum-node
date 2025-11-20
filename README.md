# Ethereum Node Setup

This repository provides a comprehensive Docker Compose setup for running Ethereum nodes. It supports multiple execution and consensus clients, validators, and additional services like MEV-Boost.

**Key Features:**
- 🚀 Single unified startup script for Linux and macOS
- 📦 Modular architecture - each service in its own directory
- 🔧 No dependencies - just Docker Compose
- 🔐 Auto-generated JWT secret
- 🎯 Simple configuration via environment variables

**Important:** Run only ONE execution client with ONE consensus client at a time. For validators, we use separate keystore directories for each client to prevent double-signing.

# Requirements

## Linux

- Docker with Compose
```bash
sudo apt update -y
sudo apt install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo groupadd docker
sudo usermod -aG docker $USER
```

## macOS

- Docker with Compose: [docker.com](https://docs.docker.com/desktop/install/mac-install/)

# Quick Start

## 1. Clone the repo

```bash
git clone https://github.com/Sensei-Node/ethereum-node.git && cd ethereum-node
```

## 2. Configure environment

Copy the `default.env` file to `.env` and modify which services you want to run:

```bash
cp default.env .env
nano .env  # or use your preferred editor
```

Edit the service flags to enable the clients you want:
```bash
# Example: Run Nethermind + Lighthouse
START_NETHERMIND=true
START_LIGHTHOUSE_CC=true
```

Copy and configure service-specific environment files as needed:

```bash
# Copy environment templates
cp environments/default.env.execution environments/.env.execution
cp environments/default.env.consensus environments/.env.consensus
# etc. for other services you enabled

# Edit them with your specific configuration
nano environments/.env.execution
nano environments/.env.consensus
```

## 3. Start services

The new unified script works on both Linux and macOS:

```bash
./node.sh
```

The JWT secret (`secrets/jwt.hex`) will be automatically generated on first run if it doesn't exist.

# Usage

```bash
./node.sh              # Start all configured services
./node.sh stop         # Stop all services
./node.sh restart      # Restart services
./node.sh logs         # View logs (all services)
./node.sh logs execution  # View specific service logs
./node.sh status       # Check running services
./node.sh pull         # Update Docker images
./node.sh config       # Validate configuration
```

# Quick Setup Examples

## RPC Node (Nethermind + Lighthouse)
```bash
# In .env
START_NETHERMIND=true
START_LIGHTHOUSE_CC=true
```

## Validator Node (Geth + Lighthouse + MEV)
```bash
# In .env
START_GETH=true
START_LIGHTHOUSE_CC=true
START_LIGHTHOUSE_VC=true
START_MEV_BOOST=true

# Additional steps:
# 1. Place keystores in keystores/lighthouse/
# 2. Set V_PASSPHRASE in environments/.env.validator
# 3. Set V_FEE_RECIPIENT in environments/.env.validator
```

## Archive Node (Erigon + Lighthouse)
```bash
# In .env
START_ERIGON=true
START_LIGHTHOUSE_CC=true
```

# Directory Structure

```
ethereum-node/
├── node.sh                     # Main management script
├── .env                        # Main configuration
├── default.env                 # Configuration template
├── docker-compose.base.yml     # Base network config
├── docker-compose.nginx.yml    # Nginx proxy
│
├── execution/                  # Execution clients
│   ├── geth/
│   │   ├── docker-compose.yml
│   │   ├── docker-compose.clef.yml
│   │   ├── README.md
│   │   └── data/               # Chain data (gitignored)
│   ├── nethermind/
│   │   ├── docker-compose.yml
│   │   ├── README.md
│   │   └── data/               # Chain data (gitignored)
│   ├── besu/
│   │   ├── docker-compose.yml
│   │   ├── README.md
│   │   └── data/               # Chain data (gitignored)
│   ├── reth/
│   │   ├── docker-compose.yml
│   │   ├── README.md
│   │   └── data/               # Chain data (gitignored)
│   └── erigon/
│       ├── docker-compose.yml
│       ├── README.md
│       └── data/               # Chain data (gitignored)
│
├── consensus/                  # Consensus clients  
│   ├── lighthouse/
│   │   ├── docker-compose.yml
│   │   ├── docker-compose.validator.yml
│   │   ├── README.md
│   │   └── data/               # Beacon chain data (gitignored)
│   └── nimbus/
│       ├── docker-compose.yml
│       ├── README.md
│       └── data/               # Beacon chain data (gitignored)
│
├── mev-boost/                  # MEV-Boost service
│   └── docker-compose.yml
│
├── execbackup/                 # Execution backup/failover
│   └── docker-compose.yml
│
├── socat/                      # Network interceptor
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── scripts/                    # Entrypoint scripts
│   ├── geth/
│   ├── nethermind/
│   ├── besu/
│   ├── reth/
│   ├── erigon/
│   ├── lighthouse/
│   ├── nimbus/
│   ├── mev-boost/
│   └── socat/
│
├── environments/               # Service-specific configs
│   ├── .env.execution
│   ├── .env.consensus
│   ├── .env.validator
│   ├── .env.mev
│   └── .env.execbackup
│
├── scripts/                    # Service entrypoint scripts
│   ├── geth/start-execution.sh
│   ├── nethermind/start-execution.sh
│   ├── besu/start-execution.sh
│   ├── reth/start-execution.sh
│   ├── erigon/start-execution.sh
│   ├── lighthouse/start-consensus.sh
│   ├── nimbus/start-consensus.sh
│   ├── mev-boost/start.sh
│   └── socat/start.sh
│
├── keystores/                  # Validator keys
│   ├── lighthouse/
│   └── nimbus/
│
└── secrets/                    # JWT secret (auto-generated)
    └── jwt.hex
```
./node.sh logs              # All services
./node.sh logs execution    # Specific service

# Check status
./node.sh status
./node.sh ps

# Pull latest images
./node.sh pull

# Validate configuration
./node.sh config
```

# Available Services

## Execution Clients (Choose ONE)

- `START_NETHERMIND=true` - Nethermind (C#) - Recommended for most users
- `START_BESU=true` - Hyperledger Besu (Java) - Enterprise-ready
- `START_GETH=true` - Go Ethereum - Most battle-tested
- `START_RETH=true` - Reth (Rust) - Fastest sync
- `START_ERIGON=true` - Erigon (Go) - Optimized for archive nodes

## Consensus Clients

- `START_NIMBUS_CC_VC=true` - Nimbus (consensus + validator) - Lightweight
- `START_LIGHTHOUSE_CC=true` - Lighthouse consensus - Popular choice
- `START_LIGHTHOUSE_VC=true` - Lighthouse validator (requires consensus)

## Additional Services

- `START_MEV_BOOST=true` - MEV-Boost (for validators)
- `START_EXECBACKUP=true` - Execution failover
- `START_NGINX_PROXY=true` - Nginx reverse proxy
- `START_CLEF=true` - Clef signer (Geth private networks)
- `START_SOCAT=true` - Request logger

# Advanced Configuration

## Checkpoint Sync (Fast Sync)

Edit `environments/.env.consensus` to enable fast sync (~15 minutes vs days):

```bash
# Mainnet
C_CHECKPOINT_URL=https://sync.invis.tools/

# Sepolia testnet
C_CHECKPOINT_URL=https://checkpoint-sync.sepolia.ethpandaops.io/

# More endpoints: https://eth-clients.github.io/checkpoint-sync-endpoints
```

## MEV-Boost (Validators)

To enable MEV-Boost:

1. Set `START_MEV_BOOST=true` in `.env`
2. Configure relays in `environments/.env.mev`
3. Set `ENABLE_MEV=true` in `environments/.env.consensus`

## Port Reference

| Service | Port | Purpose |
|---------|------|---------|
| Execution RPC | 8545 | JSON-RPC API |
| Execution Engine | 8551 | Engine API (JWT auth) |
| Execution P2P | 30303 | Peer discovery |
| Consensus Beacon | 5052 | Beacon API |
| Consensus P2P | 9000 | Peer discovery |
| MEV-Boost | 18550 | Block builder |
| Exec Backup | 9090 | Failover API |

**Firewall:** Open ports 30303 and 9000 for optimal peer connections.

## Nginx Reverse Proxy (Domain-Based Access)

Expose your RPC and Beacon API via domain names instead of IP:port.

**Enable:**
```bash
# In .env
START_NGINX_PROXY=true
```

**Configure domains in environment files:**
```bash
# In environments/.env.execution
VIRTUAL_HOST=rpc.mynode.com
VIRTUAL_PORT=8545

# In environments/.env.consensus
VIRTUAL_HOST=beacon.mynode.com
VIRTUAL_PORT=5052
```

**Setup DNS A records pointing to your server IP, then restart:**
```bash
./node.sh restart
```

**Access your services:**
```bash
curl http://rpc.mynode.com -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

curl http://beacon.mynode.com/eth/v1/node/health
```

**⚠️ Security:** HTTP is unencrypted. For production, use SSL/TLS (Let's Encrypt), authentication, and firewall rules.

## Monitoring Sync Status

**Execution Client:**
```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'
```

**Consensus Client:**
```bash
curl http://localhost:5052/eth/v1/node/syncing
```

# Specialized Guides

- [README_ETH_RPC.md](README_ETH_RPC.md) - RPC node setup
- [README_ETH_VALIDATOR.md](README_ETH_VALIDATOR.md) - Validator setup

# Troubleshooting

## Invalid Validator Passphrase

Use single quotes for passphrases with special characters:
```bash
V_PASSPHRASE='myP@$$w0rd!'
```

## Peer Discovery Issues

- Open P2P ports (30303, 9000) in firewall/router
- Check logs for connection errors
- Consider adding trusted peers (client-specific)

## Slow Consensus Sync

- Use checkpoint sync (see above)
- If stuck, purge database and resync:
  ```bash
  ./node.sh stop
  rm -rf consensus/lighthouse/data/*  # Or your consensus client data directory
  ./node.sh
  ```

## Execution Failover Setup

For validator redundancy:

1. Enable: `START_EXECBACKUP=true`
2. Configure remote RPCs in `environments/.env.execbackup`
3. Point consensus to failover: `C_EXECUTION_ENGINE=http://failover:9090`

## Updating Client Versions

### Using Specific Versions

Edit `.env` to specify exact versions:

```bash
# Example: Update to specific versions
E_VERSION=v1.27.0        # Geth
C_VERSION=v5.0.0         # Lighthouse
MEV_VERSION=v1.7         # MEV-Boost

# For Nethermind
E_VERSION=1.25.4

# For Besu
E_VERSION=24.1.0
```

Then restart services:

```bash
./node.sh restart
```

### Using Latest Versions

If using `latest` or `stable` tags, pull new images and restart:

```bash
# Pull latest images
./node.sh pull

# Restart to use new images
./node.sh restart
```

### Recommended Upgrade Process

1. **Check release notes** for breaking changes
2. **Backup your data** (optional but recommended):
   ```bash
   # Stop services
   ./node.sh stop
   
   # Backup important data
   tar -czf backup-$(date +%Y%m%d).tar.gz keystores/ secrets/
   ```

3. **Update version in `.env`**:
   ```bash
   nano .env
   # Change E_VERSION, C_VERSION, or MEV_VERSION
   ```

4. **Restart services**:
   ```bash
   ./node.sh restart
   ```

5. **Monitor logs** for issues:
   ```bash
   ./node.sh logs
   ```

### Version Tag Examples

**Geth:**
- `latest` - Latest stable
- `v1.13.14`, `v1.14.0` - Specific versions
- `stable` - Stable release

**Nethermind:**
- `latest` - Latest stable
- `1.25.4`, `1.26.0` - Specific versions

**Lighthouse:**
- `latest` - Latest stable
- `v5.0.0`, `v5.1.0` - Specific versions

**Besu:**
- `latest` - Latest stable
- `24.1.0`, `24.3.0` - Specific versions

**Reth:**
- `latest` - Latest stable
- `v0.2.0` - Specific versions

**Erigon:**
- `latest` - Latest stable
- `v2.59.0` - Specific versions

**Nimbus:**
- `amd64-latest` - Latest for AMD64 (default)
- `arm64v8-latest` - Latest for ARM64
- `latest` - Latest for current architecture
- `v24.2.0` - Specific versions

**Important:** Nimbus requires architecture-specific tags. Use `amd64-latest` for Intel/AMD systems, not `latest`.

Find version tags at:
- Geth: https://hub.docker.com/r/ethereum/client-go/tags
- Nethermind: https://hub.docker.com/r/nethermind/nethermind/tags
- Lighthouse: https://hub.docker.com/r/sigp/lighthouse/tags
- Besu: https://hub.docker.com/r/hyperledger/besu/tags
- Reth: https://github.com/paradigmxyz/reth/pkgs/container/reth
- Erigon: https://hub.docker.com/r/thorax/erigon/tags
- Nimbus: https://hub.docker.com/r/statusim/nimbus-eth2/tags

# Private Networks (Geth)

For private networks:

1. Set in `environments/.env.execution`:
   ```bash
   E_PRIVATE_NETWORK=true
   E_NETWORK_ID=123
   E_MINER_ADDRESS=0x...
   ```

2. Place `config.toml` and `genesis.json` in `execution/geth/`

3. For Clef signer, see detailed setup in repository documentation

# License

Copyright 2024 SenseiNode

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.