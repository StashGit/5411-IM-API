#!/bin/bash

TOKEN=$1

if [[ $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X GET \
         "localhost:3000/print/pending_jobs_ids"
else
    echo "Must provide a valid access token."
fi
echo

