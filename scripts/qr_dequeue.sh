#!/bin/bash

TOKEN=$1
JOB_ID=$2

if [[ $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{\"jobs_ids\": [ \"$JOB_ID\" ]}" \
         "localhost:3000/print/dequeue"
else
    echo "Must provide a valid access token."
fi
echo

