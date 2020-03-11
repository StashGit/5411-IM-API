#!/bin/bash

TOKEN=$1
BRAND_ID=$2

if [[ $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"$BRAND_ID\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" }" \
	     stock-api-5411.herokuapp.com/stock/units
else
    echo "Must provide a valid access token and a brand id."
fi

