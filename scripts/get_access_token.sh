#!/bin/bash
HOST=$1
USR=$2
PWD=$3

if [[ $HOST && $USR && $PWD ]];
then
# Gets or creates an access tocken.
curl -H "Content-Type: application/json"   \
	 -H "Accepts: application/json" -X POST \
	 -d "{ \"email\":\"$USR\", \"password\":\"$PWD\"}" \
   	 $HOST/session/new
else
    echo "Must provide host, user email and password."
fi
