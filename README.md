# Ethereum clients and tools

This repo contains all tools and clients we use at `senseinode.com` in order to run ethereum nodes (including validator clients).
In order to make proper use of the repo, you first need to determine the clients that you wish to run. 

NOTE: Please make sure to run only a single execution client with a single consensus client. Also for security reasons, for each validator client that uses keystores folder we made a separate folder (so that there's no possible way to incur in double-signing in case of missconfiguration of services)

# Requirements

## Linux

- Docker, Docker Compose
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

- Jinja
```bash
sudo apt update
sudo apt install j2cli
```

## macOS

- Docker, Docker Compose: [docker.com](https://docs.docker.com/desktop/install/mac-install/)

- Python3 and Jinja package: 

```bash
python3 -m venv env
source env/bin/activate
pip install jinjanator
```

# How to run

## Clone the repo

```bash
git clone https://github.com/Sensei-Node/ethereum-node.git && cd ethereum-node
```

## Generate a `jwt.hex` file inside `secrets` folder

```bash
openssl rand -hex 32 | tr -d "\n" > "./secrets/jwt.hex"
```

## Preparate environment variables

Copy the `default.env` file to `.env` in the root folder and modify its values accordingly.

```bash
cp default.env .env
```

Copy the desired `default.env.*` file to `.env.*` in the environments folder and modify its values accordingly.

```bash
# where * is any valid value (consensus/execution/validator/execbackup/mev)
cp environments/default.env.* .env.*
```

# Start up services

## Option 1: All manual

### Linux

Generate the `docker-compose.yml` file using jinja
```bash
set -a
source .env # and all other environments/.env.* files that you specified
j2 docker-compose.yml.j2 > docker-compose.yml
```

### macOS

Generate the `docker-compose.yml` file using jinja
```bash
source env/bin/activate
set -a
source .env # and all other environments/.env.* files that you specified
j2 docker-compose.yml.j2 > docker-compose.yml
```

Start up the docker services
```bash
docker compose up -d
```

## Option 2: Automatic via script

### Linux

```bash
./start-services.sh
```

### macOS

```bash
./start-services-macOS.sh
```

# Custom private networks

## Using gETH client

Currently we support starting nodes on private networks via gETH execution client. In order to make use of this you need to set 2 environment variables: `E_PRIVATE_NETWORK` (set to true) and `E_NETWORK_ID` (set to the network id of private network). It is also a requirement to have `config.toml` and `genesis.json` files properly configured and placed inside the `geth` directory.

## Signing with CLEF

Clef is a middleware used for secure signing with gETH. It is usually used with private networks. In order to init CLEF (import the signer, set the rules and generate the masterseed) these steps must be done at first

```bash
# initializes the clef keystore
clef --keystore /root/.ethereum/keystore --configdir /root/.ethereum/clef --chainid $E_NETWORK_ID --suppress-bootwarn init

# imports the signer account, place file 'priv.key' inside ./execution/geth
clef --keystore /root/.ethereum/keystore --suppress-bootwarn --signersecret /root/.ethereum/clef/masterseed.json importraw /root/.ethereum/priv.key

# get the $E_MINER_ADDRESS for the priv.key account
clef --keystore /root/.ethereum/keystore --configdir /root/.ethereum/clef --chainid $E_NETWORK_ID --suppress-bootwarn setpw $E_MINER_ADDRESS

# attest the shasum of the rules file
clef --keystore /root/.ethereum/keystore --configdir /root/.ethereum/clef --chainid $E_NETWORK_ID --suppress-bootwarn attest $(shasum -a 256 /root/.ethereum/clef/rules.js | cut -f1)
```

For the last step, the `shasum -a 256 rules.js | cut -f1` might need to be done separately, and input the hash for attestation.

Also it is required to have prepared in order to start the CLEF signer a rules.js file (sample is included)

# Run ethereum holesky RPC node docs

There is a specific readme for running an ethereum holesky RPC node with nethermind and lighthouse [README_ETH_RPC.md](README_ETH_RPC.md)

# Node mainteinance and troubleshooting

## Invalid passphrase for keystores

If there are special characters on the passphrase string (like $) sometimes it gets striped. So in order for this issue not to occur make sure to suround passphrase in single quotes on the .env file (or on the docker-compose.yml if variables are set in there). Eg. `V_PASSPHRASE='d3$2ed&422.#'`

## Peers not being discovered

There are some cases where for some networks you are not able to find peers. This can be due to the network not having enough peers, or having the node in a region that is isolated from other peers (like some small country). For these cases you could try either of the following: 
- Open local p2p ports in your router (execution client 30303/udp and 30303tcp);
- Move your node to another location; 
- Or you could try adding trusted peers. 

The latter depends on the client used, for instance for [geth client](https://geth.ethereum.org/docs/fundamentals/peer-to-peer).

## Consensus client slow sync

Since consensus client supports checkpoint sync, having it synced is something that should take a few minutes (in good network conditions). If for some reason it got out of sync (power interruption, network interruption, etc.) and the logs state that it is far behind, you could try dropping the databse and re-sync it from scratch. 

You can achieve this either by doing a db purge (in lighthouse for instance it is done by starting the node with the flag `--purge-db`), or simply stop the node, remove `consensus/lighthouse/holesky` and re-start it. (This is assuming you used lighthouse holesky as client and network).

Checkpoint sync endpoints can be gathered from here https://eth-clients.github.io/checkpoint-sync-endpoints

## Execution client failover

In case you want to have execution client redundancy, so that if one fails validators won't cease to perform their duties, a useful tool called [execution-backup](https://github.com/TennisBowling/executionbackup) is included. It was developed by `TennisBowling`, we addapted it to be used with docker and docker-compose. For setting it up you should:
- Enable it in the `.env` by setting `START_EXECBACKUP=true`;
- Edit the `environments/.env.consensus` file and set `C_EXECUTION_ENGINE=http://failover:9090` (note that the port will depend on the `PORT=9090` variable being set in the `environments/.env.execbackup` file);
- Fill with proper variable values on the file `environments/.env.execbackup`.

## Client version update

In case you want to perform an update to any of the clients, you should do so by specifying the version tag in the `.env`, and then perform a `docker compose down` followed by a [clean startup](#start-up-services).

Note: if using `latest`/`stable` tags, you could try with a `docker compose pull` and, if changes were pulled, perform a `docker compose up -d` instead of the above described steps.

# License

Copyright 2024 SenseiNode

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.