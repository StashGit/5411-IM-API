
#!/bin/bash

TOKEN=$1
NAME=$2

if [[ $TOKEN ]];
then
    curl -H "Content-Type: application/json" \
        -H "Access-Token: $TOKEN" \
        -X POST \
        -d "{ \"name\": \"$NAME\" }" \
        localhost:3000/brands/create
else
    echo "Must provide a valid access token."
fi

