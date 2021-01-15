#!/bin/bash
##
##  sign-user-cert.sh - sign using our root CA the user cert
##  Copyright (c) 2000 Yeak Nai Siew, All Rights Reserved. 
##

export readonly this_dir=$(cd "$(dirname $0)";pwd)
source $this_dir/ssl-vars.sh

CERT=$1
certCrtFile="${OUTPUT_DIR}/$CERT.crt"

if [ $# -ne 1 ]; then
  echo "Usage: $0 user@email.address.com"
  exit 1
fi
if [ ! -f ${OUTPUT_DIR}/$CERT.csr ]; then
  echo "No ${OUTPUT_DIR}/$CERT.csr found. You must create that first."
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
  mkdir ${DIR_CA_DB_CERTS}
fi
if [ ! -f ${FILE_CA_DB_SERIAL} ]; then
  echo '01' >${FILE_CA_DB_SERIAL}
fi
if [ ! -f ca.db.index ]; then
  cp /dev/null ca.db.index
fi

#  create the CA requirement to sign the cert
cat >ca.config <<EOT
[ ca ]
default_ca              = default_CA
[ default_CA ]
dir                     = .
certs                   = \$dir
new_certs_dir           = ${DIR_CA_DB_CERTS}
database                = \$dir/ca.db.index
serial                  = ${FILE_CA_DB_SERIAL}
RANDFILE                = ${RANDOM_SRC}
certificate             = ${FILE_CA_CRT}
private_key             = ${FILE_CA_KEY}
default_days            = ${CLIENT_VALID_DAYS}
default_crl_days        = 30
default_md              = $HASHALGO
preserve                = yes
x509_extensions         = user_cert
policy                  = policy_anything
[ policy_anything ]
commonName              = supplied
emailAddress            = supplied
[ user_cert ]
#SXNetID                = 3:yeak
subjectAltName          = email:copy
basicConstraints        = critical,CA:false
authorityKeyIdentifier  = keyid:always
extendedKeyUsage        = clientAuth,emailProtection
EOT

#  revoke an existing old certificate
if [ -f ${certCrtFile} ]; then
  openssl ca -revoke ${certCrtFile} -config ca.config
fi

#  sign the certificate
echo "CA signing: ${OUTPUT_DIR}/$CERT.csr -> ${certCrtFile}:"
openssl ca -config ca.config -out ${certCrtFile} -infiles ${OUTPUT_DIR}/$CERT.csr
echo "CA verifying: ${certCrtFile} <-> CA cert"
openssl verify -CAfile ${FILE_CA_CRT} ${certCrtFile}

#  cleanup after SSLeay 
rm -f ca.config
rm -f ${FILE_CA_DB_SERIAL}.old
rm -f ca.db.index.old
