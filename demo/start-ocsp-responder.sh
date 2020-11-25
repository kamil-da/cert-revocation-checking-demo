#!/usr/bin/env bash

source config.sh

cd $CERTS_DIR

start_ocsp_responder() {
    # Start OCSP responder
    sleep 2
    netstat -an | grep ^tcp | grep 2560

    $OPENSSL ocsp -port 2560 -text \
        -index "$CERTS_DIR/index.txt" \
        -CA "$CERTS_DIR/ca.cert.pem" \
        -rkey "$CERTS_DIR/ocsp.key.pem" \
        -rsigner "$CERTS_DIR/ocsp.cert.pem" \
        -nrequest 1
}

start_ocsp_responder
