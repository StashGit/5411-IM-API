#!/bin/bash
HOST=$1
TOKEN=$2
ID=$3
FIRST=$4

if [[ $HOST && $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X PUT \
         -d "{
         	\"user\": {
	        	\"first_name\": \"$FIRST\"
	    	}
	    }" \
         $HOST/users/$ID
else
	"Must provide host and user token"
fi

