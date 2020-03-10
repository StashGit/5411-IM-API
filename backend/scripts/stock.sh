#!/bin/bash

TOKEN=$1

if [[ $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
        -H "Access-Token: $TOKEN" \
        -X GET \
		-d '{ "style": "SS200105S", "color": "MIDNIGHT", "size": "AU6 US2" }' \
        localhost:3000/stock/units.json
else
    echo "Must provide a valid access token."
fi

