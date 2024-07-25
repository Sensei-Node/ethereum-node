# Execution API backup Dockerized

## Variables set up

### Database variables
- DB_HOST=openexecution-db (openexecution-db is the container name)
- POSTGRES_DB=<database name>
- POSTGRES_PASSWORD=<database password>
- POSTGRES_PORT=<database port> (default is 45432, if changed do it on docker-compose.yml as well)
- POSTGRES_USER=<database username>

### Ethereum node variables
JWT_SECRET=<jwttoken> (of the Engine API nodes)
EXECUTION_API_ETH_NODE=<eth execution api and port>
INSECURE_ETH_NODE=<insecure eth rpc ip/url and port>

### Openexecution server variables
LISTEN_ADDR=0.0.0.0
LISTEN_PORT=9091
LOG_LEVEL=info (Possible values: `TRACE DEBUG INFO WARN ERROR CRITICAL`)