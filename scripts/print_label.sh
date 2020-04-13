#!/bin/bash

TOKEN=$1
ID=$2

if [[ $TOKEN && $ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"id\": $ID }" \
         localhost:3000/stock/print_label
else
    echo "Must provide a valid access token and a QR ID."
fi

