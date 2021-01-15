#!/bin/bash
##
##  p12.sh - Collect the user certs and pack into pkcs12 format
##  Copyright (c) 2000 Yeak Nai Siew, All Rights Reserved. 
##

set -e

export readonly this_dir=$(cd "$(dirname $0)";pwd)
source $this_dir/ssl-vars.sh

CERT=$1
certKeyFile="${OUTPUT_DIR}/$CERT.key"
certCrtFile="${OUTPUT_DIR}/$CERT.crt"

if [ $# -ne 1 ]; then
  echo "Usage: $0 user@email.address.com"
  exit 1
fi

# Check for requirement
if [ ! -f ${certKeyFile} -o ! -f ${certCrtFile} -o ! -f ${FILE_CA_CRT} ]; then
  echo ""
  echo "Cannot proceed because:"
  echo "1. Must have root CA certification"
  echo "2. Must have ${certKeyFile}"
  echo "1. Must have ${certCrtFile}"
  echo ""
  exit 1
fi

username="`openssl x509 -noout  -in ${certCrtFile} -subject | sed -e 's;.*CN=;;' -e 's;/Em.*;;'`"
caname="`openssl x509 -noout  -in ${FILE_CA_CRT} -subject | sed -e 's;.*CN=;;' -e 's;/Em.*;;'`"

# Package it.
openssl pkcs12 \
  -export \
  -in "${certCrtFile}" \
  -inkey "${certKeyFile}" \
  -certfile ${FILE_CA_CRT} \
  -name "$username" \
  -caname "$caname" \
  -out ${OUTPUT_DIR}/$CERT.p12

echo ""
echo "The certificate for $CERT has been collected into a pkcs12 file."
echo "You can download to your browser and import it."
echo ""
