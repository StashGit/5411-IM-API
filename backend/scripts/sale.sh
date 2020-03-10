#!/bin/bash

TOKEN=$1
BRAND_ID=$2
USER_ID=$3
UNITS=$4

if [[ $TOKEN && $BRAND_ID && $USER_ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"$BRAND_ID\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" , \"user_id\": \"$USER_ID\", \"units\":"$UNITS" }" \
         localhost:3000/stock/sale
else
    echo "Must provide a valid access token and a brand name."
fi

