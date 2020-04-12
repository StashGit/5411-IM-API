#!/bin/bash

TOKEN=$1

if [[ $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"qr_ids\": \"\" }" \
         localhost:3000/stock/mass_print_labels
else
    echo "Must provide a valid access token."
fi

