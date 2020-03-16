#!/bin/bash

# Uploads an excel file an creates the stock transactions.
# It's important to use a *valid* access tocken. If this token
# doesn't works, create a brand new one by running the create_session script.
TOKEN=$1
BRAND_ID=$2
FILE=$3

if [[ $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: multipart/mixed"   \
         -H "Accepts: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -F "file=@$FILE" \
         -F "brand_id=$BRAND_ID" \
         localhost:3000/stock/import
else
    echo "Must provide a valid access token and a brand id."
fi

