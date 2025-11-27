#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found. Please create one based on .env.example"
    exit 1
fi

# Check if APIFY_TOKEN is set
if [ -z "$APIFY_TOKEN" ]; then
    echo "Error: APIFY_TOKEN is not set in .env file"
    exit 1
fi

# Actor ID
ACTOR_ID="shu8hvrXbJbY3Eb9W"

# Read accounts from data/accounts.txt and build the directUrls array
ACCOUNTS_FILE="data/accounts.txt"

if [ ! -f "$ACCOUNTS_FILE" ]; then
    echo "Error: $ACCOUNTS_FILE not found"
    exit 1
fi

# Build JSON array of directUrls
DIRECT_URLS=""
while IFS= read -r account || [ -n "$account" ]; do
    # Skip empty lines
    if [ -z "$account" ]; then
        continue
    fi

    # Remove whitespace and carriage returns
    account=$(echo "$account" | tr -d '[:space:]')

    if [ -z "$DIRECT_URLS" ]; then
        DIRECT_URLS="\"https://www.instagram.com/$account/\""
    else
        DIRECT_URLS="$DIRECT_URLS, \"https://www.instagram.com/$account/\""
    fi
done < "$ACCOUNTS_FILE"

# Build the request body
REQUEST_BODY=$(cat <<EOF
{
    "addParentData": false,
    "directUrls": [$DIRECT_URLS],
    "enhanceUserSearchWithFacebookPage": false,
    "isUserReelFeedURL": false,
    "isUserTaggedFeedURL": false,
    "onlyPostsNewerThan": "9 days",
    "resultsLimit": 18,
    "resultsType": "posts",
    "searchLimit": 1
}
EOF
)

echo "Making API request to Apify..."
echo "Accounts to scrape: $DIRECT_URLS"
echo ""

# Make the API call
RESPONSE=$(curl -L "https://api.apify.com/v2/acts/$ACTOR_ID/runs" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer $APIFY_TOKEN" \
    -d "$REQUEST_BODY" \
    -w "\n%{http_code}" \
    -s)

# Extract HTTP status code (last line) and response body (everything else)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

echo "HTTP Status Code: $HTTP_CODE"
echo ""
echo "Response:"
echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"

if [ "$HTTP_CODE" -eq 201 ] || [ "$HTTP_CODE" -eq 200 ]; then
    echo ""
    echo "✓ Successfully started Apify actor run"
else
    echo ""
    echo "✗ Failed to start actor run"
    exit 1
fi
