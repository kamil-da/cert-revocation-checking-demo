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
        -nrequest 1 &

    sleep 3
}

check_client_revokation() {
    # Check OCSP response
    $OPENSSL ocsp -CAfile "$CERTS_DIR/ca.cert.pem" \
        -url http://127.0.0.1:2560 -resp_text \
        -issuer "$CERTS_DIR/ca.cert.pem" \
        -cert "$CERTS_DIR/client.cert.pem"
}

# Revoking certificate
$OPENSSL ca -batch -config "$CERTS_DIR/openssl.cnf" -revoke "$CERTS_DIR/client.cert.pem"

start_ocsp_responder
check_client_revokation
