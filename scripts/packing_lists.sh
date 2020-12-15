#!/bin/bash

HOST=$1
TOKEN=$2

if [[ $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X GET \
         $HOST/stock/packing_lists
else
    echo "Must provide a valid access token and the api host."
fi

echo ""
