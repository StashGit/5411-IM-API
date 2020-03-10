#!/bin/bash

TOKEN=$1
BRAND_ID=$2

if [[ $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X GET \
         -d "{ \"brand_id\": \"$BRAND_ID\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" }" \
         localhost:3000/stock/units
else
    echo "Must provide a valid access token and a brand id."
fi

