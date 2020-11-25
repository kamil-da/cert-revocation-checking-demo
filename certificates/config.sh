#!/usr/bin/env bash

OPENSSL="/usr/local/opt/openssl/bin/openssl"
OPENSSL_CONFIG_TEMPLATE="openssl.template.cnf"

ROOTDIR=$(pwd)
CERTS_DIR="$ROOTDIR/certs"
OPENSSL_CONFIG="$CERTS_DIR/openssl.cnf"

INDEX_FILE="$CERTS_DIR/index.txt"
SERIAL_FILE="$CERTS_DIR/serial"
NEW_CERTS_DIR="$CERTS_DIR/newcerts"
