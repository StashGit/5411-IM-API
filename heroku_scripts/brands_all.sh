#!/bin/bash

TOKEN=$1

if [[ $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X GET \
	     stock-api-5411.herokuapp.com/brands/all
else
    echo "Must provide a valid access token."
fi

