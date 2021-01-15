#!/bin/bash
##
##  sign-server-cert.sh - sign using our root CA the server cert
##  Copyright (c) 2000 Yeak Nai Siew, All Rights Reserved. 
##

set -e

export readonly this_dir=$(cd "$(dirname $0)";pwd)
source $this_dir/ssl-vars.sh

CN=$1
cnCsrFile="${OUTPUT_DIR}/$CN.csr"

if [ $# -ne 1 ]; then
  echo "Usage: $0 <www.domain.com>"
  exit 1
fi
if [ ! -f ${cnCsrFile} ]; then
  echo "No ${cnCsrFile} found. You must create that first."
  exit 1
fi
# Check for root CA key
if [ ! -f ${FILE_CA_KEY} -o ! -f ${FILE_CA_CRT} ]; then
  echo "You must have root CA key generated first."
  exit 1
fi

# Sign it with our CA key #

#   make sure environment exists
if [ ! -d ${DIR_CA_DB_CERTS} ]; then
  mkdir -p ${DIR_CA_DB_CERTS}
fi
if [ ! -f ${FILE_CA_DB_SERIAL} ]; then
  echo '01' >${FILE_CA_DB_SERIAL}
fi
if [ ! -f ${FILE_CA_DB_INDEX} ]; then
  cp /dev/null ${FILE_CA_DB_INDEX}
fi

caConfigFile=${OUTPUT_DIR}/ca.config
cnCrtFile=${OUTPUT_DIR}/$CN.crt

#  create the CA requirement to sign the cert
cat >${caConfigFile} <<EOT
[ ca ]
default_ca              = default_CA
[ default_CA ]
dir                     = .
certs                   = ${OUTPUT_DIR}
new_certs_dir           = ${DIR_CA_DB_CERTS}
database                = ${FILE_CA_DB_INDEX}
serial                  = ${FILE_CA_DB_SERIAL}
RANDFILE                = ${RANDOM_SRC}
certificate             = ${FILE_CA_CRT}
private_key             = ${FILE_CA_KEY}
default_days            = ${SERVER_VALID_DAYS}
default_crl_days        = 30
default_md              = $HASHALGO
preserve                = no
x509_extensions         = server_cert
policy                  = policy_anything
[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
[ server_cert ]
#subjectKeyIdentifier   = hash
authorityKeyIdentifier  = keyid:always
extendedKeyUsage        = serverAuth,clientAuth,msSGC,nsSGC
basicConstraints        = critical,CA:false
[req]
default_md              = $HASHALGO
req_extensions          = v3_req
[ v3_req ]
extendedKeyUsage        = serverAuth, clientAuth
EOT

# Test for Subject Alternate Names
subjaltnames="`openssl req -text -noout -in ${cnCsrFile} | sed -e 's/^ *//' | grep -A1 'X509v3 Subject Alternative Name:' | tail -1 | sed -e 's/IP Address:/IP:/g'`"
if [ "$subjaltnames" != "" ]; then
    echo "Found subject alternate names: $subjaltnames"
    echo ""
    echo "subjectAltName = $subjaltnames" >> ${caConfigFile}
fi

#  revoke an existing old certificate
if [ -f ${cnCrtFile} ]; then
    echo "Revoking current certificate: ${cnCrtFile}"
    openssl ca -revoke ${cnCrtFile} -config ${caConfigFile}
fi

#  sign the certificate
echo "CA signing: ${cnCsrFile} -> ${cnCrtFile}:"
openssl ca -config ${caConfigFile} -extensions v3_req -out ${cnCrtFile} -infiles ${cnCsrFile}
echo ""
echo "CA verifying: ${cnCrtFile} <-> CA cert"
openssl verify -CAfile ${FILE_CA_CRT} ${cnCrtFile}
echo ""

#  cleanup after SSLeay 
rm -f ${caConfigFile}
rm -f ${FILE_CA_DB_SERIAL}.old
rm -f ${FILE_CA_DB_INDEX}.old
