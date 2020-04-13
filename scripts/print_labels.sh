#!/bin/bash

TOKEN=$1
PRINT_TOKEN=$2

if [[ $TOKEN && $PRINT_TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"token\" : \"$PRINT_TOKEN\" }" \
         localhost:3000/stock/print_labels
else
    echo "Must provide a valid access and print tokens ."
fi

