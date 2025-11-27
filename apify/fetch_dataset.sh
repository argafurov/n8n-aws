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

# Check if dataset ID is provided
if [ -z "$1" ]; then
    echo "Error: Dataset ID is required"
    echo "Usage: $0 <dataset_id>"
    echo "Example: $0 qxfIqwWMgTIA15Ao5"
    exit 1
fi

DATASET_ID="$1"
OUTPUT_FILE="data/${DATASET_ID}.json"

# Create data directory if it doesn't exist
mkdir -p data

echo "Fetching dataset: $DATASET_ID"
echo "Output file: $OUTPUT_FILE"
echo ""

# Make the API call
RESPONSE=$(curl -L "https://api.apify.com/v2/datasets/$DATASET_ID/items" \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer $APIFY_TOKEN" \
    -w "\n%{http_code}" \
    -s)

# Extract HTTP status code (last line) and response body (everything else)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    # Save the response to file
    echo "$RESPONSE_BODY" > "$OUTPUT_FILE"

    echo "HTTP Status Code: $HTTP_CODE"
    echo ""
    echo "✓ Successfully fetched dataset"
    echo "✓ Data saved to: $OUTPUT_FILE"

    # Display summary if jq is available
    if command -v jq &> /dev/null; then
        ITEM_COUNT=$(echo "$RESPONSE_BODY" | jq '. | length' 2>/dev/null)
        if [ -n "$ITEM_COUNT" ]; then
            echo "✓ Total items: $ITEM_COUNT"
        fi
    fi
else
    echo "HTTP Status Code: $HTTP_CODE"
    echo ""
    echo "Error Response:"
    echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
    echo ""
    echo "✗ Failed to fetch dataset"
    exit 1
fi
