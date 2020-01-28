#!/bin/bash

docker-compose -f ./docker-compose-build.yaml -f ./android-emulator-container-scripts/js/docker/development.yaml -f ./docker-compose.yaml up --build
