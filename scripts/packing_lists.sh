#!/bin/bash

HOST=$1
TOKEN=$2
BRAND_ID=$3

if [[ $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X GET \
         $HOST/stock/packing_lists?brand_id=$BRAND_ID
else
    echo "Must provide a valid access token, the api host and a brand_id."
fi

echo ""
