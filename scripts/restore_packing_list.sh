#!/bin/bash

# Permite recuperar todas las transacciones asociadas a una packing list.
HOST=$1
TOKEN=$2
PLID=$3

if [[ $HOST && $TOKEN && $PLID ]];
then
    curl -H "Content-Type: multipart/mixed"   \
         -H "Accepts: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -F "packing_list_id=$PLID" \
		 $HOST/stock/restore_packing_list
else
    echo "Must provide host, a valid access token and a packing list id."
fi

echo ""
