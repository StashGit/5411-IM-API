#!/bin/bash
HOST=$1
TOKEN=$2
ID=$3

if [[ $HOST && $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X DELETE \
         $HOST/users/$ID
else
	"Must provide host and user token"
fi

echo
echo

