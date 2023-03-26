#!/bin/bash
set -ex
apt update
apt-get install nginx -y
INSTANCE_ID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/id" -H "Metadata-Flavor: Google")
VM_MACHINE_UUID=$(sudo cat /sys/devices/virtual/dmi/id/product_uuid |tr '[:upper:]' '[:lower:]')
echo "This message was generated on instance $INSTANCE_ID with the following UUID $VM_MACHINE_UUID" > $INSTANCE_ID.txt
gsutil cp ./$INSTANCE_ID.txt gs://epam-gcp-tf-lab-bjsdqv
cp ./$INSTANCE_ID.txt /var/www/html/index.html
echo "Done!"