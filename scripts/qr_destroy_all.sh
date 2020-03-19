#!/bin/bash

TOKEN=$1
if [[ $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X DELETE \
         localhost:3000/qr/destroy_all
else
    echo "Must provide a valid access token."
fi

