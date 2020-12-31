#!/bin/bash

HOST=$1
TOKEN=$2
BRAND_ID=$3
UNITS=$4

if [[ $HOST && $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"$BRAND_ID\",
                \"sku_from\": {
                    \"style\": \"SS200105S\",
                    \"color\": \"MIDNIGHT\",
                    \"size\": \"AU6 US2\",
                    \"code\":\"test-code\",
                    \"reference_id\":\"ref-1\",
                    \"box_id\":\"box-1\"
                },
                \"sku_to\": {
                    \"style\": \"SS200105S\",
                    \"color\": \"MIDNIGHT\",
                    \"size\": \"AU6 US2\",
                    \"code\":\"test-code\",
                    \"reference_id\":\"ref-2\",
                    \"box_id\":\"box-2\"
                },
                \"units\":"$UNITS",
                \"comments\":\"This is a comment.\" }" \
         $HOST/stock/move
else
    echo "Must provide host, a valid access token and a brand id."
fi

