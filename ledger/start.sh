#!/usr/bin/env bash

ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CERTS_DIR="$ROOTDIR/../certificates/certs"
SERVER_CERT="$CERTS_DIR/server.cert.pem"
SERVER_KEY="$CERTS_DIR/server.pem"
CA_CERT="$CERTS_DIR/ca.cert.pem"

PROJECT="test-project"
PROJECT_DIR="$ROOTDIR/$PROJECT"

cd $ROOTDIR
rm -rf $PROJECT_DIR
daml new $PROJECT
cd $PROJECT
daml sandbox --pem $SERVER_KEY --crt $SERVER_CERT --cacrt $CA_CERT --cert-revocation-checking true
