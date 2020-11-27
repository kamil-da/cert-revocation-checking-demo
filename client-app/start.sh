#!/usr/bin/env bash

ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CERTS_DIR="$ROOTDIR/../certificates/certs"
JAR="$ROOTDIR/client.jar"
CLIENT_CERT="$CERTS_DIR/client.cert.pem"
CLIENT_KEY="$CERTS_DIR/client.pem"
CA_CERT="$CERTS_DIR/ca.cert.pem"

cd $ROOTDIR
sbt assembly
cp target/scala-2.12/client.jar $JAR
java -jar $JAR localhost 6865 $CLIENT_CERT $CLIENT_KEY $CA_CERT
