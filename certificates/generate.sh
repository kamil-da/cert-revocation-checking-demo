#!/usr/bin/env bash

ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $ROOTDIR/config.sh

rm -rf $CERTS_DIR
mkdir $CERTS_DIR

cat "$ROOTDIR/$OPENSSL_CONFIG_TEMPLATE" | sed -e "s;<ROOTDIR>;$CERTS_DIR;g" > $OPENSSL_CONFIG

cd $CERTS_DIR

touch $INDEX_FILE
echo 1000 > $SERIAL_FILE
mkdir $NEW_CERTS_DIR

# Generate Root CA private key
$OPENSSL genrsa -out $CERTS_DIR/ca.key.pem 4096
chmod 400 $CERTS_DIR/ca.key.pem
# Create Root Certificate (self-signed)
$OPENSSL req -config $OPENSSL_CONFIG \
    -key $CERTS_DIR/ca.key.pem \
    -new -x509 -days 7300 -sha256 -extensions v3_ca \
    -subj '/CN=0.0.0.0.ca' \
    -out $CERTS_DIR/ca.cert.pem
# Dump out cert details
$OPENSSL x509 -noout -text -in $CERTS_DIR/ca.cert.pem

# Generate Server private key
$OPENSSL genrsa -out $CERTS_DIR/server.key.pem 4096
$OPENSSL pkey -in $CERTS_DIR/server.key.pem -out $CERTS_DIR/server.pem
chmod 400 $CERTS_DIR/server.key.pem
# Create Server certificate
$OPENSSL req -config $OPENSSL_CONFIG \
    -subj '/CN=0.0.0.0.server' \
    -addext "subjectAltName = DNS:localhost, IP:127.0.0.1" \
    -key $CERTS_DIR/server.key.pem \
    -new -sha256 -out $CERTS_DIR/server.csr.pem

# Sign Certificate
$OPENSSL ca -batch -config $OPENSSL_CONFIG \
    -extensions server_cert -days 365 -notext -md sha256 \
    -in $CERTS_DIR/server.csr.pem \
    -out $CERTS_DIR/server.cert.pem
chmod 444 $CERTS_DIR/server.cert.pem

$OPENSSL x509 -noout -text \
    -in $CERTS_DIR/server.cert.pem

# Generate Client CA private key
# $OPENSSL genpkey -out $CERTS_DIR/client.key.pem -algorithm RSA -pkeyopt rsa_keygen_bits:2048
$OPENSSL genrsa -out $CERTS_DIR/client.key.pem 4096
$OPENSSL pkey -in $CERTS_DIR/client.key.pem -out $CERTS_DIR/client.pem
$OPENSSL req -new -key $CERTS_DIR/client.pem \
    -subj '/CN=0.0.0.0.client' \
    -addext "subjectAltName = DNS:localhost, IP:127.0.0.1" \
    -out $CERTS_DIR/client.csr.pem
# Sign Client Cert
$OPENSSL ca -batch -config $OPENSSL_CONFIG \
    -extensions usr_cert -notext -md sha256 \
    -in $CERTS_DIR/client.csr.pem \
    -out $CERTS_DIR/client.cert.pem
# Validate cert is correct
$OPENSSL verify -CAfile $CERTS_DIR/ca.cert.pem \
    $CERTS_DIR/client.cert.pem

# Generate OCSP Server private key
$OPENSSL genrsa \
    -out $CERTS_DIR/ocsp.key.pem 4096
# Sign OCSP Server certificate
$OPENSSL req -config $OPENSSL_CONFIG -new -sha256 \
    -subj '/CN=ocsp.127.0.0.1' \
    -key $CERTS_DIR/ocsp.key.pem \
    -out $CERTS_DIR/ocsp.csr.pem
$OPENSSL ca -batch -config $OPENSSL_CONFIG \
    -extensions ocsp -days 375 -notext -md sha256 \
    -in $CERTS_DIR/ocsp.csr.pem \
    -out $CERTS_DIR/ocsp.cert.pem
# Validate extensions
$OPENSSL x509 -noout -text \
    -in $CERTS_DIR/ocsp.cert.pem

start_ocsp_responder() {
    # Start OCSP responder
    sleep 2
    netstat -an | grep ^tcp | grep 2560

    $OPENSSL ocsp -port 2560 -text \
        -index $INDEX_FILE \
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

start_ocsp_responder
check_client_revokation
