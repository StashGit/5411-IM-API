#!/bin/bash

# Uploads logo and returns the image id (See Image model.)
TOKEN=$1
BRAND_ID=$2
FILE=$3

if [[ $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: multipart/mixed"   \
         -H "Accepts: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -F "image=@$FILE" \
         localhost:3000/utils/upload_image
else
    echo "Must provide a valid access token and a brand id."
fi

