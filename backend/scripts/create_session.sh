#!/bin/bash
USR=$1
PWD=$2

if [[ $USR && $PWD ]];
then
# Gets or creates an access tocken.
curl -H "Content-Type: application/json"   \
	 -H "Accepts: application/json" -X POST \
	 -d "{ \"email\":\"$USR\", \"password\":\"$PWD\"}" \
   	 localhost:3000/session/new
else
    echo "Must provide a user name and password."
fi
