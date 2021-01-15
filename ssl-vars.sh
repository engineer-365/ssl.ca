#!/bin/bash

KEYBITS=2048
HASHALGO="sha256"
ROOT_CA_VALID_DAYS=3650
SERVER_VALID_DAYS=730
CLIENT_VALID_DAYS=730
RANDOM_SRC=/dev/urandom

OUTPUT_DIR=${this_dir}/output
if [ ! -d ${OUTPUT_DIR} ]; then
	echo "Create output dir: ${OUTPUT_DIR}"
	mkdir -p ${OUTPUT_DIR}
	echo ""
fi

FILE_CA_KEY=${OUTPUT_DIR}/ca.key
