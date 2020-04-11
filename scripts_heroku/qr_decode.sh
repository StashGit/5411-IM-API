#!/bin/bash
TOKEN=$1
ID=$2

if [[ $ID ]];
then
curl -H "Content-Type: application/json"   \
	 -H "Access-Token: $TOKEN" \
	 -H "Accepts: application/json" -X POST \
	 -d "{ \"id\":\"$ID\" }" \
	 stock-api-5411.herokuapp.com/qr/decode
else
    echo "Must provide a QR id."
fi
echo
