#!/bin/bash

TOKEN=$1
ID=$2
COPIES=$3

if [[ $TOKEN && $ID && $COPIES ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"qrs\": [ { \"id\": $ID, \"copies\": $COPIES } ] }" \
         localhost:3000/stock/mass_print_labels
else
    echo "Must provide a valid access token, QR ID and the number of copies."
fi

