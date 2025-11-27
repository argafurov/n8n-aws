# Apify API Scripts

This directory contains shell scripts for interacting with the Apify API.

## Prerequisites

- `curl` - for making HTTP requests
- `jq` - (optional) for pretty-printing JSON responses
- Apify API token - get yours from [Apify Console](https://console.apify.com/account/integrations)

## Setup

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your Apify API token:
   ```bash
   APIFY_TOKEN=your_actual_token_here
   ```

## Available Scripts

### 1. `submit_posts_scraping_job.sh` - Run Instagram Scraper Actor

This script runs the Apify Instagram scraper actor for a list of Instagram accounts.

**Usage:**
```bash
./submit_posts_scraping_job.sh
```

**Prerequisites:**
- Create `data/accounts.txt` with Instagram usernames (one per line)

**What it does:**
- Reads Instagram account usernames from `data/accounts.txt`
- Triggers the Apify Instagram scraper actor
- Scrapes the latest posts from specified accounts
- Returns information about the started actor run

**Example `data/accounts.txt`:**
```
instagram_username1
instagram_username2
instagram_username3
```

### 2. `fetch_dataset.sh` - Fetch Dataset Results

This script fetches data from an Apify dataset and saves it to a JSON file.

**Usage:**
```bash
./fetch_dataset.sh <dataset_id>
```

**Example:**
```bash
./fetch_dataset.sh qxfIqwWMgTIA15Ao5
```

**What it does:**
- Fetches all items from the specified Apify dataset
- Saves the results to `data/<dataset_id>.json`
- Displays a summary of items fetched

**Output:**
- Results are saved to `data/<dataset_id>.json`
- Example: `data/qxfIqwWMgTIA15Ao5.json`

## Typical Workflow

1. **Start a scraping job:**
   ```bash
   ./submit_posts_scraping_job.sh
   ```

   This will return a response with a `defaultDatasetId` field.

2. **Fetch the results:**
   ```bash
   ./fetch_dataset.sh <defaultDatasetId>
   ```

3. **Check the results:**
   ```bash
   cat data/<defaultDatasetId>.json | jq '.'
   ```

## Directory Structure

```
apify/
├── .env                            # Your API credentials (not tracked in git)
├── .env.example                    # Template for environment variables
├── submit_posts_scraping_job.sh    # Script to run Instagram scraper actor
├── fetch_dataset.sh                # Script to fetch dataset results
├── README.md                       # This file
└── data/
    ├── accounts.txt                # Instagram accounts to scrape
    └── *.json                      # Dataset results (generated)
```

## Error Handling

Both scripts include error handling for common issues:
- Missing `.env` file
- Missing `APIFY_TOKEN`
- Invalid dataset ID
- API errors (non-200/201 responses)

## API Documentation

For more information about the Apify API:
- [Apify API Reference](https://docs.apify.com/api/v2)
- [Dataset API](https://docs.apify.com/api/v2#/reference/datasets)
- [Actor Runs API](https://docs.apify.com/api/v2#/reference/actors/run-collection)
