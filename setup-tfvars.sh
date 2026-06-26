#!/bin/bash

OUTPUT_FILE=${OUTPUT_FILE:-terraform.tfvars}
TEMP_DIR=$(mktemp -d)

[ -f $OUTPUT_FILE ] && { echo "$OUTPUT_FILE exists, refusing to proceed"; exit 1; }
[ -z "$1" ] && { echo "Please specify domain name"; exit 1;}

openssl req -x509 \
  -newkey rsa:4096 \
  -nodes \
  -keyout $TEMP_DIR/privkey.pem \
  -out $TEMP_DIR/fullchain.pem \
  -days 365 \
  -subj "/C=RU/ST=Moscow oblast/L=Moscow/O=DevOps&CO/OU=IT/CN=$1"

cat <<EOL > $OUTPUT_FILE
timeweb_token = ""

rke2_token = $(openssl rand -hex 16)

ssl_privkey = <<-EOT
$(cat ${TEMP_DIR}/privkey.pem)
EOT

ssl_fullchain = <<-EOT
$(cat ${TEMP_DIR}/fullchain.pem)
EOT
EOL

trap "rm -rf $TEMP_DIR" EXIT