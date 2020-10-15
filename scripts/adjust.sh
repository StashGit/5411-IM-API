#!/bin/bash

TOKEN=$1
BRAND_ID=$2
UNITS=$3
REASON=$4

if [[ $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"$BRAND_ID\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" ,\"code\":\"test-code\",\"units\":"$UNITS", \"comments\":\"This is a comment.\", \"reason\" : \"$REASON\" }" \
         localhost:3000/stock/adjust
else
    echo "Must provide a valid access token and a brand id."
fi

