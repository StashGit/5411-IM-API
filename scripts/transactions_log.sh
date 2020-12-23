#!/bin/bash

HOST=$1
TOKEN=$2
BRAND_ID=$3

if [[ $HOST && $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: multipart/mixed"   \
         -H "Accepts: application/json" \
         -H "Access-Token: $TOKEN" \
         -X GET \
         $HOST/stock/log?brand_id=$BRAND_ID
else
    echo "Must provide host, a valid access token, and a brand_id."
fi

