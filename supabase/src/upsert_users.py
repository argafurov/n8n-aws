import os
import json
from typing import Any, Dict, List
from dotenv import load_dotenv

from supabase import create_client, Client

# Load environment variables from .env file
load_dotenv()

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


def get_supabase_client() -> Client:
    return create_client(SUPABASE_URL, SUPABASE_KEY)


def process_user_json(user: Dict[str, Any]) -> Dict[str, Any]:
    """
    Convert Instagram user JSON to database row format.

    JSON fields -> DB fields mapping:
    - username -> username
    - fullName -> full_name
    - profilePicUrl -> profile_pic_url
    - postsCount -> posts_count
    - followersCount -> followers_count
    - followsCount -> follows_count
    - private -> is_private
    - verified -> is_verified
    - isBusinessAccount -> is_business_account
    - biography -> biography
    """

    user_row = {
        "username": user.get("username"),
        "full_name": user.get("fullName"),
        "profile_pic_url": user.get("profilePicUrl"),
        "posts_count": user.get("postsCount"),
        "followers_count": user.get("followersCount"),
        "follows_count": user.get("followsCount"),
        "is_private": user.get("private", False),
        "is_verified": user.get("verified", False),
        "is_business_account": user.get("isBusinessAccount", False),
        "biography": user.get("biography"),
    }

    return user_row


def upsert_instagram_users(data: List[Dict[str, Any]]) -> None:
    """
    Upserts Instagram user data into n8n_ig.users table.

    Args:
        data: List of user objects from Instagram API/scraper

    The upsert uses username as the conflict key since users don't have
    an instagram_id in the JSON, and username is unique.
    """
    supabase = get_supabase_client()

    users_buffer: List[Dict[str, Any]] = []

    # Process all users
    for user in data:
        user_row = process_user_json(user)
        users_buffer.append(user_row)

    # Upsert users
    if users_buffer:
        print(f"Upserting {len(users_buffer)} users...")
        supabase.schema("n8n_ig").table("users").upsert(
            users_buffer,
            on_conflict="username"
        ).execute()

        print("Done.")
    else:
        print("No users to upsert.")


if __name__ == "__main__":
    # --- LOCAL TESTING SECTION ---
    #
    # Load JSON from file
    import sys

    json_file = sys.argv[1] if len(sys.argv) > 1 else "data/users.json"

    with open(json_file, "r", encoding="utf-8") as f:
        instagram_users = json.load(f)

    upsert_instagram_users(instagram_users)
