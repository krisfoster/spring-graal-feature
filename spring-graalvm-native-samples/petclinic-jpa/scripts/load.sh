#!/usr/bin/env bash

REPORT_DIR=$1
mkdir -p $REPORT_DIR

echo "Deleteing old test data and plots"
rm $REPORT_DIR/load-*.dat
rm /$REPORT_DIR/*-profplot.png

echo "Load testing the openjdk petclinic..."
THREADS=2
CONNS=2
WARM_UP=180s
DURRATION=60s

# Warm up - try run for 5 mins
wrk2 -t${THREADS} -c${CONNS} -d${WARM_UP} -R200 \
      --latency http://localhost:8081/owners\?lastName\=

# Run tests for 2 mins for better data
for val in 50 80 100 150;
do
  echo "Load test output to ../target/logs/openjdk-load-${val}.dat;"
  wrk2 -t${THREADS} -c${CONNS} -d${DURRATION} -R${val} \
      --latency http://localhost:8081/owners\?lastName\= > $REPORT_DIR/load-${val}.dat;
done;

echo "Generating plot..."
cat $REPORT_DIR/load-*.dat | wrk2img $REPORT_DIR/load-latency.png
#open $REPORT_DIR/load-latency.png