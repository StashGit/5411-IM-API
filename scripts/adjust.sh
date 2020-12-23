#!/bin/bash

HOST=$1
TOKEN=$2
BRAND_ID=$3
UNITS=$4
# Reason es una especie de enum que utilizamos para indicar el tipo de transaccion
# 1 == BUY, 2 == SALE, etc...
REASON=$5

if [[ $HOST && $TOKEN && $BRAND_ID ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{
            \"brand_id\":     \"$BRAND_ID\",
            \"style\":        \"TROUSERS\",
            \"color\":        \"250\",
            \"size\":         \"XS\",
            \"code\":         \"1012\",
            \"box_id\":       \"BOX 4\",
            \"reference_id\": \"PO123\",
            \"units\":        "$UNITS",
            \"comments\":     \"This is a comment.\",
            \"reason\":       \"$REASON\"
         }" \
         $HOST/stock/adjust
else
    echo "Must provide a host, a valid access token, and a brand id."
fi

echo ""
