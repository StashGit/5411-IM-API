#!/bin/bash

TOKEN=$1

if [[ $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         "localhost:3000/print/dequeue_all"
else
    echo "Must provide a valid access token."
fi
echo

