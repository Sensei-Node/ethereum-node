# Execution API backup Dockerized

## Variables set up

- NODES: comma separated values of Engine API nodes socket (ex. `10.0.0.1:8551,10.0.0.2:8551`)
- PORT: port to be exposed. Default is 9090, if changed make sure to change `docker-compose.yml` file as well.
- LOG_LEVEL: Possible values: `TRACE DEBUG INFO WARN ERROR CRITICAL`
- JWT_SECRET: of the Engine API nodes
