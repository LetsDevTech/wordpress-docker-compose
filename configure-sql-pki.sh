#!/bin/bash

ECURVE=prime256v1
PKIDIR=./sql/pki
mkdir -p ${PKIDIR}
# default options
echo "authorityKeyIdentifier  = keyid, issuer:always" > ${PKIDIR}/openssl.cnf

# cria pk da CA
# openssl genrsa -out ${PKIDIR}/ca.key 2048
openssl ecparam -genkey -text -name "${ECURVE}" -outform PEM -out ${PKIDIR}/ca.key
openssl req -x509 -days 3650 -key ${PKIDIR}/ca.key -out ${PKIDIR}/ca.crt \
            -subj "/CN=SQL-Internal-CA" \
            -addext "keyUsage=keyCertSign,cRLSign,digitalSignature" \
            -batch


openssl ecparam -genkey -text -name "${ECURVE}" -outform PEM -out ${PKIDIR}/sql.key
openssl req -key ${PKIDIR}/sql.key -out ${PKIDIR}/sql.csr -new \
        -addext "basicConstraints=CA:FALSE" \
        -addext "subjectKeyIdentifier=hash" \
        -addext "keyUsage=digitalSignature,keyEncipherment" \
        -addext "extendedKeyUsage=clientAuth,serverAuth" \
        -addext "subjectAltName=DNS:db" \
        -subj "/CN=sql"

openssl x509 -req -in ${PKIDIR}/sql.csr -CA ${PKIDIR}/ca.crt -CAkey ${PKIDIR}/ca.key \
                -days 3650 -CAcreateserial -out ${PKIDIR}/sql.crt \
                -CAcreateserial \
                -CAserial ${PKIDIR}/serial \
                -next_serial \
                -extfile ${PKIDIR}/openssl.cnf \
                -copy_extensions "copy" \
                -sha256

openssl verify -trusted ${PKIDIR}/ca.crt ${PKIDIR}/sql.crt

echo '[mariadb]
tls_version = TLSv1.2,TLSv1.3
ssl_cert = /etc/mysql/ssl/sql.crt
ssl_key = /etc/mysql/ssl/sql.key
ssl_ca = /etc/mysql/ssl/ca.crt ' > "${PKIDIR}/tls.cnf"

sudo chown -R 999\:999 "${PKIDIR}"