#!/bin/bash

TOKEN=$1
BRAND_ID=$2
NAME=$3

if [[ $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"id\": \"$BRAND_ID\", \"name\": \"$NAME\" }" \
         localhost:3000/brands/update
else
    echo "Must provide a valid access token and a brand id."
fi

