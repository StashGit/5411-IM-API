#!/bin/bash

TOKEN=$1

if [[ $TOKEN ]];
then
    curl -H "Content-Type: multipart/mixed"   \
        -H "Accepts: application/json" \
        -H "Access-Token: $TOKEN" \
        -X GET \
        localhost:3000/stock/log.json
else
    echo "Must provide a valid access token."
fi

