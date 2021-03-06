#!/usr/bin/env bash

ARTIFACT=data-redis
VERSION=0.0.1-SNAPSHOT

MAIN_CLASS=com.example.data.redis.RedisApplication
JAR_FILE=${ARTIFACT}-${VERSION}.jar

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

mkdir -p target/ni
cd target/ni || exit
jar -xvf ../${JAR_FILE}
cp -R META-INF BOOT-INF/classes
LIBPATH=`find BOOT-INF/lib | tr '\n' ':'`
CP=BOOT-INF/classes:${LIBPATH}

# Other parmas we may need
#--enable-all-security-services \
native-image \
    --verbose \
    --allow-incomplete-classpath \
    --no-fallback \
    -H:Name=${ARTIFACT} \
    -H:+TraceClassInitialization \
    -H:+ReportExceptionStackTraces \
    -H:+StaticExecutableWithDynamicLibC \
    -Dspring.spel.ignore=true \
    -Dspring.native.remove-yaml-support=true \
    -cp ${CP} \
    ${MAIN_CLASS}

if [[ -f $ARTIFACT ]]
then
  printf "${GREEN}SUCCESS${NC}\n"
  mv ./$ARTIFACT ../../builds/target
  exit 0
else
  cat output.txt
  printf "${RED}FAILURE${NC}: an error occurred when compiling the native-image.\n"
  exit 1
fi

