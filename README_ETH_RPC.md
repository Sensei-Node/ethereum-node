# Ethereum mainnet RPC node

In this demo we will be launching an Ethereum mainnet RPC node, that will use lighthouse and nethermind as the consensus and execution clients respectively.

## Run the node

### Pre-requisites

All the seme requirements apply as described in the [README.md](README.md) (docker, docker-compose, jinja)

### Clone the repo

```bash
git clone https://github.com/Sensei-Node/ethereum-node.git && cd ethereum-node
```

### Generate a `jwt.hex` file inside `secrets` folder

```bash
openssl rand -hex 32 | tr -d "\n" > "./secrets/jwt.hex"
```

### Configure environment variables

Copy the `default.env` file to `.env` in the root folder.
Copy the desired `default.env.*` file to `.env.*` in the environments folder.

```bash
cp default.env .env
cp environments/default.env.execution environments/.env.execution
cp environments/default.env.consensus environments/.env.consensus
```

### Prepare the environment files

We need to prepare the environment variables in the files for the required ethereum rpc node. 
In the `.env` file leave all variables the same, and set the following variables to true:

```bash
START_NETHERMIND=true
START_LIGHTHOUSE_CC=true
```

### (macOS only) Start docker daemon

For macOS you will need to start docker daemon by opening docker app. In linux this step is not required

### Start the node

#### Linux

```bash
./start-services.sh
```

#### macOS

```bash
./start-services-macOS.sh
```

## View node logs

You can check current node status by getting all container logs

```bash
docker compose logs -f 
```

## Stop the node

This will stop all running containers in the current workdir

```bash
docker compose down
```

## Extra: Run a validator

If you would like to add validator capabilities to your recently launched node, you can do so by following the steps specified in this [README_ETH_VALIDATOR.md](README_ETH_VALIDATOR.md)

## Useful node API calls

### Execution client sync status

Returns an object with data about the sync status or false

```bash
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' http://localhost:8545
```

### Consensus client sync status

Requests the beacon node to describe if it's currently syncing or not, and if it is, what block it is up to

```bash
curl -X GET -H "Content-Type: application/json" http://localhost:5052/eth/v1/node/syncing
```


### Official API docs

- [Beacon node API](https://ethereum.github.io/beacon-APIs/)
- [JSON-RPC Execution API](https://ethereum.org/en/developers/docs/apis/json-rpc/)