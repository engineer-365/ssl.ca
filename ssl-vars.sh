#!/bin/bash

KEYBITS=2048
HASHALGO="sha256"
ROOT_CA_VALID_DAYS=3650
SERVER_VALID_DAYS=730
CLIENT_VALID_DAYS=730
RANDOM_SRC=/dev/urandom
ORG_NAME="example-org"

OUTPUT_DIR=${this_dir}/output
if [ ! -d ${OUTPUT_DIR} ]; then
  echo "Create output dir: ${OUTPUT_DIR}"
  mkdir -p ${OUTPUT_DIR}
  echo ""
fi

FILE_CA_KEY=${OUTPUT_DIR}/ca.key
FILE_CA_CRT=${OUTPUT_DIR}/ca.crt
FILE_DEFAULT_SERVER_KEY=${OUTPUT_DIR}/server.key
FILE_DEFAULT_USER_KEY=${OUTPUT_DIR}/user.key
DIR_CA_DB_CERTS=${OUTPUT_DIR}/ca.db.certs
FILE_CA_DB_SERIAL=${OUTPUT_DIR}/ca.db.serial

