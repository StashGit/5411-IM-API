#!/bin/bash

TOKEN=$1
BRAND_ID=$2
UNITS=$3

if [[ $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"$BRAND_ID\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" ,\"units\":"$UNITS", \"comments\":\"This is a comment.\" }" \
         localhost:3000/stock/adjust
else
    echo "Must provide a valid access token and a brand id."
fi

