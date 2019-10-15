#!/usr/bin/env bash


for d in */; do
    # Will print */ if no directories are available
    docker-compose -f ./$d/docker-compose.yml up -d
done
