#! /usr/bin/env bash

docker swarm init
docker stack deploy -c docker-compose.yaml artb-3pg-lab2-swarm
