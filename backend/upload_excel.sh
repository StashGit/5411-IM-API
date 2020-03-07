#!/bin/bash

# Uploads an excel file an creates the stock transactions.
# It's important to use a *valid* access tocken. If this token
# doesn't works, create a brand new one by running the create_session script.
curl -H "Content-Type: multipart/mixed"   \
	 -H "Accepts: application/json" \
	 -H "Access-Token: 1a095eeeb9783e43b8369171e1dbf98a" \
	 -X POST \
	 -F "file=@../data/pl1.xlsx" \
   	 localhost:3000/stock/upload.json

