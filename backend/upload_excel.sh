#!/bin/bash

# Gets or creates an access tocken.
curl -H "Content-Type: multipart/mixed"   \
	 -H "Accepts: application/json" \
	 -H "Access-Token: 1a095eeeb9783e43b8369171e1dbf98a" \
	 -X POST \
	 -F "file=@../data/pl1.xlsx" \
   	 localhost:3000/stock/upload.json

