#!/bin/bash

# Uploads logo and returns the image id (See Image model.)
HOST=$1
TOKEN=$2
BRAND_ID=$3
FILE=$4

if [[ $HOST && $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: multipart/mixed"   \
         -H "Accepts: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -F "image=@$FILE" \
         "$HOST"/utils/upload_image
else
    echo "Must provide host, a valid access token and a brand id."
fi

