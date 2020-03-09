#!/bin/bash

# Uploads an excel file an creates the stock transactions.
# It's important to use a *valid* access tocken. If this token
# doesn't works, create a brand new one by running the create_session script.
TOKEN=$1

if [[ $TOKEN ]];
then
    curl -H "Content-Type: multipart/mixed"   \
        -H "Accepts: application/json" \
        -H "Access-Token: $TOKEN" \
        -X POST \
        -F "file=@../../data/pl1.xlsx" \
        localhost:3000/stock/upload.json
else
    echo "Must provide a valid access token."
fi

