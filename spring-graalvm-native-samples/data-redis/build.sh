#!/usr/bin/env bash

ARTIFACT=data-redis
MAINCLASS=com.example.data.redis.RedisApplication
VERSION=0.0.1-SNAPSHOT

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

printf "=== ${BLUE}Building %s sample${NC} ===\n" "${PWD##*/}"

############## Build Jar ######################
printf "=== ${BLUE}Building jar...${NC} ===\n"
rm -rf target
mkdir -p target/native-image
echo "Packaging $ARTIFACT with Maven"
mvn -ntp package > target/native-image/output.txt
printf "=== ${BLUE}Jar file created...${NC} ===\n"

############## Build Native Image on Docker ######################
printf "=== ${BLUE}Building on Docker${NC} ===\n"

./compile.sh && ${PWD%/*samples/*}/scripts/test.sh
