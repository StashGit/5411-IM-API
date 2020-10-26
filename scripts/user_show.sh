#!/bin/bash
HOST=$1
TOKEN=$2
EMAIL=$3

if [[ $HOST && $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         $HOST/users/by_email?email=$EMAIL
else
	"Must provide host and user token"
fi

echo
echo

