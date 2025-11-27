# n8n AWS Infrastructure

This repository contains multiple AWS deployments and data processing tools:

## Table of Contents

1. [Infrastructure (n8n + Terraform)](#part-1-infrastructure-n8n--terraform)
2. [OpenWebUI EC2](#part-2-openwebui-ec2)
3. [Apify Instagram Scraping](#part-3-apify-instagram-data-scraping)
4. [Supabase Local Database](#part-4-supabase-local-database)

---

# Part 1: Infrastructure (n8n + Terraform)

## Overview

Deploys n8n workflow automation on AWS EC2 with:

- EC2 (Ubuntu, eu-central-1)
- Docker + docker-compose
- Local Postgres + n8n
- nginx reverse proxy
- Let's Encrypt TLS for `https://n8n.example.com`
- **No SSH** – access via **SSM Session Manager**

## Prerequisites

1. AWS account + IAM user with permissions to:
   - EC2, VPC, EIP, Route 53, IAM, SSM
2. Domain `example.com` in Namecheap
3. Public hosted zone in Route 53 for `example.com` and Namecheap nameservers pointing to AWS
4. EC2 key pair created (used only as metadata; SSH port is closed)
5. AWS CLI v2 installed and `aws configure` done (with region `eu-central-1`)

## Structure

```text
terraform/   # infrastructure (VPC, EC2, EIP, Route53, IAM role for SSM)
cloud-init/  # user_data script (installs docker, nginx, certbot, n8n)
```

## Deployment Steps

### 1. Configure Terraform Variables

Edit `terraform/terraform.tfvars`:

```hcl
domain           = "n8n.example.com"
route53_zone_id  = "Z0123456789ABCDEFGHIJ"
email            = "you@example.com"
key_name         = "my-ec2-key"
```

### 2. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Access n8n

- **n8n UI**: `https://n8n.example.com`
- **SSH via SSM**: `aws ssm start-session --target <instance-id>`

### 4. Manage Instance

Connect to the instance using SSM Session Manager:

```bash
# Get instance ID from Terraform outputs
aws ssm start-session --target i-xxxxxxxxxxxxx

# Once connected, manage services
sudo docker ps                  # View running containers
sudo systemctl status nginx     # Check nginx status
sudo certbot renew --dry-run    # Test certificate renewal
```

---

# Part 2: OpenWebUI EC2

## Overview

Deploys Open WebUI on a separate EC2 instance with:

- Docker + Open WebUI container
- nginx reverse proxy
- Let's Encrypt SSL/TLS
- OpenAI API integration

## Deployment

The OpenWebUI EC2 instance is deployed using the same Terraform infrastructure with a different `cloud-init` script located at `cloud-init/openwebui_user_data.tpl`.

## Features

- Accessible via HTTPS with automatic SSL certificate provisioning
- Runs Open WebUI v0.6.40-slim in Docker
- OpenAI API key configured via environment variables
- Automatic certificate renewal via systemd timer

## Access

Once deployed, access Open WebUI at:
- `https://openwebui.example.com` (replace with your configured domain)

---

# Part 3: Apify Instagram Data Scraping

## Overview

Scripts for scraping Instagram data using the Apify platform.

## Directory Structure

```text
apify/
├── .env                            # Your API credentials (not tracked in git)
├── .env.example                    # Template for environment variables
├── submit_posts_scraping_job.sh    # Script to run Instagram scraper actor
├── fetch_dataset.sh                # Script to fetch dataset results
├── README.md                       # Apify documentation
└── data/
    ├── accounts.txt                # Instagram accounts to scrape
    └── *.json                      # Dataset results (generated)
```

## Setup

### 1. Get Apify API Token

Get your API token from [Apify Console](https://console.apify.com/account/integrations)

### 2. Configure Environment

```bash
cd apify
cp .env.example .env
# Edit .env and add your token:
# APIFY_TOKEN=your_actual_token_here
```

### 3. Create Accounts List

Create `data/accounts.txt` with Instagram usernames (one per line):

```text
instagram_username1
instagram_username2
instagram_username3
```

## Usage Workflow

### Step 1: Submit Scraping Job

Run the Instagram scraper actor:

```bash
cd apify
./submit_posts_scraping_job.sh
```

The script will:
- Read Instagram usernames from `data/accounts.txt`
- Trigger the Apify Instagram scraper actor
- Return a response with a `defaultDatasetId`

Example output:
```json
{
  "id": "actor_run_abc123",
  "defaultDatasetId": "qxfIqwWMgTIA15Ao5",
  "status": "RUNNING"
}
```

### Step 2: Fetch Dataset Results

After the scraping job completes, fetch the JSON dataset:

```bash
./fetch_dataset.sh qxfIqwWMgTIA15Ao5
```

This will:
- Download all scraped data from Apify
- Save it to `data/qxfIqwWMgTIA15Ao5.json`
- Display a summary of items fetched

### Step 3: Verify Results

```bash
cat data/qxfIqwWMgTIA15Ao5.json | jq '.' | head -50
```

## Next Steps

Once you have the JSON dataset, proceed to [Part 4: Supabase](#part-4-supabase-local-database) to insert the data into your local database.

---

# Part 4: Supabase Local Database

## Overview

Local Supabase development environment for storing Instagram data in a PostgreSQL database with custom `n8n_ig` schema.

## Directory Structure

```text
supabase/
├── config.toml                      # Supabase configuration
├── migrations/
│   └── 20251126000000_init_db.sql   # Initial database schema
├── requirements.txt                 # Python dependencies
├── .env.example                     # Environment template
├── .env                             # Your credentials (not tracked)
└── src/
    ├── upsert_posts.py              # Main data insertion script
    └── upsert_users.py              # User data insertion script
```

## Database Schema

The `n8n_ig` schema includes:

**Entity Tables:**
- `posts` - Instagram posts (images, videos, carousels)
- `comments` - Comments on posts
- `tagged_users` - Users tagged in posts
- `coauthor_producers` - Coauthor/collaborator accounts

**Junction Tables:**
- `post_child_posts` - Parent-child relationships (carousels)
- `post_tagged_users` - Many-to-many posts ↔ tagged users
- `post_coauthor_producers` - Many-to-many posts ↔ coauthors
- `post_latest_comments` - Latest comments mapping

## Setup

### 1. Install Supabase CLI

See the [Installing the Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started?queryGroups=platform&platform=linux&queryGroups=access-method&access-method=postgres#installing-the-supabase-cli) docs page

### 2. Start Supabase Locally

```bash
cd supabase
supabase start
```

This starts all Supabase services:
- **API URL**: `http://127.0.0.1:54321`
- **Studio UI**: `http://127.0.0.1:54323`
- **Database**: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`

The initial migration (`migrations/20251126000000_init_db.sql`) will run automatically, creating the `n8n_ig` schema and all tables.

### 3. Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your Supabase credentials:

```bash
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_KEY=your_service_role_key_from_supabase_start_output
```

**Note**: When you run `supabase start`, it will display the service role key. Copy it to your `.env` file.

### 4. Install Python Dependencies

```bash
# From the supabase/ directory
pip install -r requirements.txt
```

Or if using a virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

## Initialize Database

The database is automatically initialized when you run `supabase start`. The migration file creates:
- Schema `n8n_ig`
- All tables with proper constraints and indexes
- Triggers for automatic `updated_at` timestamps
- Permissions for anon, authenticated, and service_role

To manually reset and reinitialize:

```bash
supabase db reset
```

This will:
- Drop all tables
- Rerun all migrations

## Insert Data from Apify

### Step 1: Copy JSON Dataset

Copy the Apify dataset JSON file to the `supabase/data/` directory:

```bash
# From the repository root
cp apify/data/qxfIqwWMgTIA15Ao5.json supabase/data/posts.json
```

### Step 2: Run Upsert Script

```bash
cd supabase
python src/upsert_posts.py data/posts.json
```

Or if the file is named differently:

```bash
python src/upsert_posts.py data/qxfIqwWMgTIA15Ao5.json
```

### What the Script Does

The `upsert_posts.py` script:

1. **Reads JSON data** from the Apify dataset
2. **Flattens hierarchical structure** (posts → childPosts → comments)
3. **Normalizes data** into separate tables (posts, comments, tagged_users, etc.)
4. **Creates relationships** using junction tables
5. **Upserts data** to Supabase (updates existing records or inserts new ones)

The script processes:
- ✅ Posts (images, videos, carousels)
- ✅ Child posts (carousel slides)
- ✅ Comments and latest comments
- ✅ Tagged users
- ✅ Coauthor producers
- ✅ All relationships between entities

### Example Output

```
Upserting 150 posts...
Upserting 45 tagged users...
Upserting 12 coauthor producers...
Upserting 320 comments...
Creating 45 post-tagged_users relationships...
Creating 12 post-coauthor relationships...
Creating 89 parent-child post relationships...
Creating 320 post-latest_comments relationships...
Done.
```

## Verify Data

### Using Supabase Studio

Open the Supabase Studio UI:

```bash
# Open in browser
open http://127.0.0.1:54323
```

Navigate to:
- **Table Editor** → Select schema `n8n_ig` → Browse tables
- **SQL Editor** → Run custom queries

### Using SQL Queries

```sql
-- Count posts by type
SELECT type, COUNT(*)
FROM n8n_ig.posts
GROUP BY type;

-- Get posts with their tagged users
SELECT
  p.instagram_id,
  p.caption,
  array_agg(tu.username) as tagged_usernames
FROM n8n_ig.posts p
LEFT JOIN n8n_ig.post_tagged_users ptu ON p.id = ptu.post_id
LEFT JOIN n8n_ig.tagged_users tu ON ptu.tagged_user_id = tu.id
GROUP BY p.id, p.instagram_id, p.caption;

-- Get carousel posts with their child posts
SELECT
  parent.instagram_id as parent_id,
  parent.caption,
  child.instagram_id as child_id,
  pcp.position
FROM n8n_ig.posts parent
JOIN n8n_ig.post_child_posts pcp ON parent.id = pcp.parent_post_id
JOIN n8n_ig.posts child ON pcp.child_post_id = child.id
ORDER BY parent.id, pcp.position;

-- Get posts with comment count
SELECT
  p.instagram_id,
  p.caption,
  COUNT(c.id) as actual_comments_count
FROM n8n_ig.posts p
LEFT JOIN n8n_ig.comments c ON p.id = c.post_id
GROUP BY p.id, p.instagram_id, p.caption;
```

## Common Operations

### Stop Supabase

```bash
supabase stop
```

### Create New Migration

```bash
supabase migration new add_new_field_to_posts
```

Then edit the generated file in `migrations/` and run:

```bash
supabase db push
```

### View Logs

```bash
supabase logs db
```

### Access Database Directly

```bash
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

Then in psql:

```sql
\c postgres
SET search_path TO n8n_ig;
\dt
SELECT * FROM posts LIMIT 5;
```

## Data Flow Summary

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  1. Apify Instagram Scraper                             │
│     └─> Submit job (submit_posts_scraping_job.sh)       │
│     └─> Fetch dataset (fetch_dataset.sh)                │
│     └─> Save to apify/data/<dataset_id>.json            │
│                                                         │
│  2. Copy JSON to Supabase directory                     │
│     └─> cp apify/data/*.json supabase/data/             │
│                                                         │
│  3. Insert into Supabase                                │
│     └─> python src/upsert_posts.py data/posts.json      │
│                                                         │
│  4. Query and analyze data                              │
│     └─> Supabase Studio (http://127.0.0.1:54323)        │
│     └─> SQL queries via psql or Studio                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Supabase won't start

```bash
# Check Docker is running
docker ps

# Reset Supabase completely
supabase stop
supabase db reset
```

### Python script errors

```bash
# Verify environment variables
cat .env

# Check Supabase is running
supabase status

# Verify database connection
python -c "from supabase import create_client; print('OK')"
```

### Permission errors

Make sure you're using the **service_role** key (not anon key) in your `.env` file. The service role key bypasses Row Level Security (RLS) policies.

## Resources

- [Supabase Local Development Docs](https://supabase.com/docs/guides/cli/local-development)
- [Apify API Documentation](https://docs.apify.com/api/v2)
- [n8n Documentation](https://docs.n8n.io/)
