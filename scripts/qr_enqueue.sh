#!/bin/bash

TOKEN=$1
QR_ID=$2
COPIES=$3

if [[ $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{\"jobs\": [{ 
             \"qr_id\": \"$QR_ID\", 
             \"copies\": \"$COPIES\" }]}" \
         "localhost:3000/print/enqueue"
else
    echo "Must provide a valid access token."
fi
echo

