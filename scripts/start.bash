#!/bin/bash

xhost +local:docker > /dev/null || true

CONTAINER_NAME=$1

docker start -i ${CONTAINER_NAME}
