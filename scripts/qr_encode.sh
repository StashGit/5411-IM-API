#!/bin/bash

TOKEN=$1
BRAND_ID=$2
STYLE=$3
COLOR=$4
SIZE=$5

if [[ $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"$BRAND_ID\", \"style\": \"$STYLE\", \"color\": \"$COLOR\", \"size\": \"$SIZE\" }" \
         localhost:3000/qr/encode
else
    echo "Must provide a valid access token."
fi
echo

