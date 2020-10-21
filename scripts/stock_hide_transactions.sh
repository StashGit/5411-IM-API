#!/bin/bash
TOKEN=$1
BRAND_ID=$2
STYLE=$3
COLOR=$4

curl -H "Content-Type: application/json" \
     -H "Accepts: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -d "{
          \"brand_id\": \"$BRAND_ID\",
          \"style\":    [ \"$STYLE\" ],
          \"color\":    [ \"$COLOR\" ]
        }" \
     localhost:3000/stock/hide

echo ""
echo ""
