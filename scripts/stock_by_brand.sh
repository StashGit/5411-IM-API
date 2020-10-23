#!/bin/bash

HOST=$1
TOKEN=$2
BRAND_ID=$3

if [[ $HOST && $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"$BRAND_ID\" }" \
         $HOST/stock/by_brand
else
    echo "Must provide host, access token, and a brand id."
fi

echo
echo

