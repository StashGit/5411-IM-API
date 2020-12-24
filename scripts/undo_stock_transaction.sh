#!/bin/bash

HOST=$1
TOKEN=$2
TXN_ID=$3

if [[ $HOST && $TOKEN && $TXN_ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{
            \"transaction_id\": \"$TXN_ID\"
         }" \
         $HOST/stock/undo_transaction
else
    echo "Must provide a host, a valid access token, and a transaction id."
fi

echo ""
