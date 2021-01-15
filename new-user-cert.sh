#!/bin/bash
##
##  new-user-cert.sh - create the user cert for personal use.
##  Copyright (c) 2000 Yeak Nai Siew, All Rights Reserved. 
##

set -x

export readonly this_dir=$(cd "$(dirname $0)";pwd)
source $this_dir/ssl-vars.sh


# Create the key. This should be done once per cert.
CERT=$1
certKeyFile="${OUTPUT_DIR}/$CERT.key"

if [ $# -ne 1 ]; then
        echo "Usage: $0 user@email.address.com"
        exit 1
fi

# if private key exists, ask if we want to generate a new key
if [ -f ${certKeyFile} ]; then
  read -p "a key for this cn is already existing, generate a new one? " ANSWER
  if [ "$ANSWER" == "Y" ] || [ "$ANSWER" == "y" ]; then
    rm -f ${certKeyFile}
  fi
fi

if [ ! -f ${certKeyFile} ]; then
	echo "No ${certKeyFile} found. Generating one"
	openssl genrsa -out ${certKeyFile} $KEYBITS
	echo ""
fi

# Fill the necessary certificate data
CONFIG="${OUTPUT_DIR}/user-cert.conf"
cat >$CONFIG <<EOT
[ req ]
default_bits			= $KEYBITS
default_keyfile			= ${FILE_DEFAULT_USER_KEY}
default_md              = $HASHALGO
distinguished_name		= req_distinguished_name
string_mask			= nombstr
req_extensions			= v3_req
[ req_distinguished_name ]
commonName			= Common Name (eg, John Doe)
commonName_max			= 64
emailAddress			= Email Address
emailAddress_max		= 40
[ v3_req ]
subjectKeyIdentifier=hash
basicConstraints = critical,CA:FALSE
keyUsage = digitalSignature
extendedKeyUsage = codeSigning, msCodeInd, msCodeCom
nsCertType = client, email, objsign
EOT

echo "Fill in certificate data"
openssl req -new -config $CONFIG -key ${certKeyFile} -out $CERT.csr

rm -f $CONFIG

echo ""
echo "You may now run ./sign-user-cert.sh to get it signed"
