#!/bin/bash
docker stop peer1-org1
docker rm peer1-org1

docker stop peer2-org1
docker rm peer2-org1

docker stop peer1-org2
docker rm peer1-org2

docker stop peer2-org2
docker rm peer2-org2
