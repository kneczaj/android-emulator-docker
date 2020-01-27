#!/bin/bash

docker-compose -f ./docker-compose-build.yaml -f ./docker-compose.yaml up --build
