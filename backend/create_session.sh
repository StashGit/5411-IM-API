#!/bin/bash

# Gets or creates an access tocken.
curl -H "Content-Type: application/json"   \
	 -H "Accepts: application/json" -X POST \
	 -d '{ "email":"john@example.com", "password":"123"}' \
   	 localhost:3000/session/new.json
