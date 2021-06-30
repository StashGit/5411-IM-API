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
         $HOST/stock/delete_brand_transactions
else
    echo "Must provide a valid host, access token, and brand id."
fi
