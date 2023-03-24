#!/bin/bash
INSTANCE_ID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/id" -H "Metadata-Flavor: Google")
VM_MACHINE_UUID=$(sudo cat /sys/devices/virtual/dmi/id/product_uuid |tr '[:upper:]' '[:lower:]')
cat << EOF > ${INSTANCE_ID}.txt
echo "This message was generated on instance ${INSTANCE_ID} with the following UUID ${VM_MACHINE_UUID}"
EOF
gsutil cp ./${INSTANCE_ID}.txt gs://epam-gcp-tf-lab-25nwcr
echo "Done!"
