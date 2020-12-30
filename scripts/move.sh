#!/bin/bash

TOKEN=$1
BRAND_ID=$2
UNITS=$3

if [[ $TOKEN && $BRAND_ID ]];
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
         localhost:3000/stock/move
else
    echo "Must provide a valid access token and a brand id."
fi

