#!/bin/bash

set -a
# Source all .env.* files
for file in ./environments/.env.*; do
  if [ -f "$file" ]; then
    source "$file"
  fi
done
# Source .env file
source .env
echo 'Updating docker-compose.yml...'
j2 docker-compose.yml.j2 > docker-compose.yml
if [ "$UPDATE_DOCKERCOMPOSE_ONLY" != "true" ]; then
  echo 'Starting services...'
  docker compose up -d --build
fi