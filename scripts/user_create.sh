#!/bin/bash
HOST=$1
TOKEN=$2
EMAIL=$3
FIRST=$4
LAST=$5
PWD=$6
PWD_CONFIRM=$7

if [[ $HOST && $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{
         	\"user\": {
	        	\"email\": \"$EMAIL\",
	        	\"first_name\": \"$FIRST\",
	        	\"last_name\": \"$LAST\" ,
	        	\"password\": \"$PWD\" ,
	        	\"password_confirmation\": \"$PWD_CONFIRM\"
	    	}
	    }" \
         $HOST/users
else
	"Must provide host and user token"
fi

