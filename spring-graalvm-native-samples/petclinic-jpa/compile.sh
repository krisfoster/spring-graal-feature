#!/usr/bin/env bash

ARTIFACT=petclinic-jpa
MAINCLASS=org.springframework.samples.petclinic.PetClinicApplication
VERSION=0.0.1-SNAPSHOT

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
#    --gc=G1 \
native-image \
    --verbose \
    --allow-incomplete-classpath \
    --no-fallback \
    --no-server \
    --enable-all-security-services \
    -H:Name=${ARTIFACT} \
    -H:TraceClassInitialization=true \
    -H:+ReportExceptionStackTraces \
    -H:+StaticExecutableWithDynamicLibC \
    --pgo-instrument \
    -R:MaxHeapSize=32m \
    -R:MaxNewSize=16m \
    -Dspring.native.remove-yaml-support=true \
    -cp ${CP} \
    ${MAINCLASS}

if [[ -f $ARTIFACT ]]
then
  printf "${GREEN}SUCCESS${NC}\n"
  mv ./$ARTIFACT /
  exit 0
else
  cat output.txt
  printf "${RED}FAILURE${NC}: an error occurred when compiling the native-image.\n"
  exit 1
fi

