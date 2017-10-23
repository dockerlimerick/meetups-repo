#!/bin/bash

if [ "$(whoami)" == 'jenkins' ]; then
    VOL="${WORKSPACE}/docker_demo_2/artifacts"
else
    VOL="/Users/david.power/Projects/docker_demo_2/artifacts"
fi

# remove old artifacts and set up new directory
rm -rf artifacts && mkdir -p artifacts

# Build the project containers
docker build -t dockerapp:latest .

# Run tests, also bringing up container dependencies
docker run --volume $VOL:/ruby-app/artifacts dockerapp:latest docker/run_tests.sh 