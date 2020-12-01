#!/bin/bash

# Uploads an excel file an creates the stock transactions.
# It's important to use a *valid* access token. If this token
# doesn't works, create a brand new one by running the create_session script.
HOST=$1
TOKEN=$2
BRAND_ID=$3
FILE=$4

if [[ $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: multipart/mixed"   \
         -H "Accepts: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -F "file=@$FILE" \
         -F "brand_id=$BRAND_ID" \
		 $HOST/stock/import
else
    echo "Must provide host, a valid access token and a brand id."
fi

