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

```bash
docker compose logs -f 
```

## Stop the node

```bash
docker compose down
```