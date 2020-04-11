#!/bin/bash
ID=$1

if [[ $ID ]];
then
curl -H "Content-Type: application/json"   \
	 -H "Accepts: application/json" -X POST \
	 -d "{ \"id\":\"$ID\" }" \
   	 localhost:3000/qr/decode
else
    echo "Must provide a QR id."
fi
echo
