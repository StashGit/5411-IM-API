#!/bin/bash

TOKEN=$1

if [[ $TOKEN ]];
then
    curl -H "Content-Type: text/html" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" }" \
         https://stock-api-5411.herokuapp.com/qr/create
else
    echo "Must provide a valid access token."
fi

