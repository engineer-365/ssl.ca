#!/bin/bash
##
##  new-root-ca.sh - create the root CA
##  Copyright (c) 2000 Yeak Nai Siew, All Rights Reserved. 
##

set -x

export readonly this_dir=$(cd "$(dirname $0)";pwd)
source $this_dir/ssl-vars.sh

# Create the master CA key. This should be done once.
if [ ! -f ${FILE_CA_KEY} ]; then
  echo "No Root CA key found. Generating one"
  openssl genrsa -aes256 -out ${FILE_CA_KEY} -rand ${RANDOM_SRC} $KEYBITS
  echo ""
fi

# Self-sign it.
CONFIG="${OUTPUT_DIR}/root-ca.conf"
cat >$CONFIG <<EOT
[ req ]
default_bits                   = $KEYBITS
default_keyfile                = ${FILE_CA_KEY}
default_md                     = $HASHALGO
distinguished_name             = req_distinguished_name
x509_extensions                = v3_ca
string_mask                    = nombstr
req_extensions                 = v3_req
[ req_distinguished_name ]
countryName                    = Country Name (2 letter code)
countryName_default            = US
countryName_min                = 2
countryName_max                = 2
stateOrProvinceName            = State or Province Name (full name)
stateOrProvinceName_default    = Texas
localityName                   = Locality Name (eg, city)
localityName_default           = Austin
0.organizationName             = Organization Name (eg, company)
0.organizationName_default     = ${ORG_NAME}
organizationalUnitName         = Organizational Unit Name (eg, section)
organizationalUnitName_default = Certification Services Division
commonName                     = Common Name (eg, MD Root CA)
commonName_default             = My Root CA
commonName_max                 = 64
emailAddress                   = Email Address
emailAddress_max               = 40
[ v3_ca ]
basicConstraints               = critical,CA:true
subjectKeyIdentifier           = hash
[ v3_req ]
nsCertType                     = objsign,email,server
EOT

echo "Self-sign the root CA..."
openssl req -new -x509 -days ${ROOT_CA_VALID_DAYS} -config $CONFIG -key ${FILE_CA_KEY} -out ${FILE_CA_CRT}

rm -f $CONFIG
