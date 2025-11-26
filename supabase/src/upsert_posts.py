import os
import json
from typing import Any, Dict, List, Optional
from dotenv import load_dotenv

from supabase import create_client, Client

# Load environment variables from .env file
load_dotenv()

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


def get_supabase_client() -> Client:
    return create_client(SUPABASE_URL, SUPABASE_KEY)


def json_array(value: Any) -> List:
    """Normalize None → empty list for array fields."""
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def process_post_json(
    post: Dict[str, Any],
    parent_post_instagram_id: Optional[str],
    posts_buffer: List[Dict[str, Any]],
    comments_buffer: List[Dict[str, Any]],
    tagged_users_buffer: List[Dict[str, Any]],
    coauthor_producers_buffer: List[Dict[str, Any]],
    child_posts_relations: List[Dict[str, Any]],
    latest_comments_relations: List[Dict[str, Any]],
    post_tagged_users_relations: List[Dict[str, Any]],
    post_coauthor_producers_relations: List[Dict[str, Any]],
) -> None:
    """
    Flatten one post (and its children & comments) into normalized rows for:
      - n8n_ig.posts
      - n8n_ig.comments
      - n8n_ig.tagged_users
      - n8n_ig.coauthor_producers
      - n8n_ig.post_child_posts (junction)
      - n8n_ig.post_latest_comments (junction)
      - n8n_ig.post_tagged_users (junction)
      - n8n_ig.post_coauthor_producers (junction)

    Everything is also stored as raw JSON for data preservation.
    """

    post_instagram_id = str(post["id"])

    # --- build post row ---
    post_row = {
        "instagram_id": post_instagram_id,
        "type": post.get("type"),
        "short_code": post.get("shortCode"),
        "caption": post.get("caption"),
        "hashtags": json_array(post.get("hashtags")),
        "mentions": json_array(post.get("mentions")),
        "url": post.get("url"),
        "comments_count": post.get("commentsCount"),
        "first_comment": post.get("firstComment"),
        "dimensions_height": post.get("dimensionsHeight"),
        "dimensions_width": post.get("dimensionsWidth"),
        "display_url": post.get("displayUrl"),
        "images": json_array(post.get("images")),
        "alt": post.get("alt"),
        "likes_count": post.get("likesCount"),
        # timestamp comes as ISO string – Postgres will parse it
        "posted_at": post.get("timestamp"),
        "location_name": post.get("locationName"),
        "location_id": post.get("locationId"),
        "owner_full_name": post.get("ownerFullName"),
        "owner_username": post.get("ownerUsername"),
        "owner_instagram_id": post.get("ownerId"),
        "is_comments_disabled": post.get("isCommentsDisabled", False),
        "input_url": post.get("inputUrl"),
        "is_sponsored": post.get("isSponsored", False),
        # video fields
        "video_url": post.get("videoUrl"),
        "video_view_count": post.get("videoViewCount"),
        "video_play_count": post.get("videoPlayCount"),
        "video_duration": post.get("videoDuration"),
        # audio and music
        "audio_url": post.get("audioUrl"),
        "music_info": post.get("musicInfo"),
        # product and pin status
        "product_type": post.get("productType"),
        "is_pinned": post.get("isPinned", False),
        # keep the full original post JSON – guarantees ALL data is preserved
        "raw": post,
    }

    posts_buffer.append(post_row)

    # --- tagged users for this post ---
    tagged_users_list = post.get("taggedUsers", []) or []
    for tu in tagged_users_list:
        tagged_user_instagram_id = str(tu.get("id")) if tu.get("id") else None

        # Add to tagged users table
        tagged_user_row = {
            "instagram_id": tagged_user_instagram_id,
            "username": tu.get("username"),
            "full_name": tu.get("full_name"),
            "profile_pic_url": tu.get("profile_pic_url"),
            "is_verified": tu.get("is_verified"),
        }
        tagged_users_buffer.append(tagged_user_row)

        # Create relationship between post and tagged user (will be resolved after inserts)
        if tagged_user_instagram_id:
            post_tagged_users_relations.append({
                "post_instagram_id": post_instagram_id,
                "tagged_user_instagram_id": tagged_user_instagram_id,
            })

    # --- coauthor producers for this post ---
    coauthor_producers_list = post.get("coauthorProducers", []) or []
    for cp in coauthor_producers_list:
        coauthor_instagram_id = str(cp.get("id")) if cp.get("id") else None

        # Add to coauthor producers table
        coauthor_row = {
            "instagram_id": coauthor_instagram_id,
            "username": cp.get("username"),
            "profile_pic_url": cp.get("profile_pic_url"),
            "is_verified": cp.get("is_verified"),
        }
        coauthor_producers_buffer.append(coauthor_row)

        # Create relationship between post and coauthor (will be resolved after inserts)
        if coauthor_instagram_id:
            post_coauthor_producers_relations.append({
                "post_instagram_id": post_instagram_id,
                "coauthor_instagram_id": coauthor_instagram_id,
            })

    # --- comments for this post ---
    latest_comments_list = post.get("latestComments", []) or []
    for position, c in enumerate(latest_comments_list):
        comment_instagram_id = str(c["id"])
        owner = c.get("owner") or {}
        comment_row = {
            "instagram_id": comment_instagram_id,
            "post_instagram_id": post_instagram_id,  # Will be resolved to post_id later
            "text": c.get("text"),
            "owner_username": c.get("ownerUsername"),
            "owner_profile_pic_url": c.get("ownerProfilePicUrl"),
            "commented_at": c.get("timestamp"),
            "replies_count": c.get("repliesCount"),
            "likes_count": c.get("likesCount"),
            "owner_instagram_id": owner.get("id"),
            "owner_raw": owner,
            "raw": c,
        }
        comments_buffer.append(comment_row)

        # Track latest comments relationship (will be resolved after inserts)
        latest_comments_relations.append({
            "post_instagram_id": post_instagram_id,
            "comment_instagram_id": comment_instagram_id,
            "position": position,
        })

    # --- recursively process childPosts as posts with parent relationship ---
    child_posts_list = post.get("childPosts", []) or []
    for position, child in enumerate(child_posts_list):
        process_post_json(
            child,
            parent_post_instagram_id=post_instagram_id,
            posts_buffer=posts_buffer,
            comments_buffer=comments_buffer,
            tagged_users_buffer=tagged_users_buffer,
            coauthor_producers_buffer=coauthor_producers_buffer,
            child_posts_relations=child_posts_relations,
            latest_comments_relations=latest_comments_relations,
            post_tagged_users_relations=post_tagged_users_relations,
            post_coauthor_producers_relations=post_coauthor_producers_relations,
        )

        # Track parent-child relationship (will be resolved after inserts)
        child_instagram_id = str(child["id"])
        child_posts_relations.append({
            "parent_instagram_id": post_instagram_id,
            "child_instagram_id": child_instagram_id,
            "position": position,
        })


def process_instagram_json(data: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Process Instagram JSON data into normalized structures without database operations.

    Args:
        data: list of top-level posts from Instagram API/Apify

    Returns:
        Dictionary containing all processed data:
        {
            "posts": [...],
            "comments": [...],
            "tagged_users": [...],
            "coauthor_producers": [...],
            "child_posts_relations": [...],
            "latest_comments_relations": [...],
            "post_tagged_users_relations": [...],
            "post_coauthor_producers_relations": [...]
        }
    """
    posts_buffer: List[Dict[str, Any]] = []
    comments_buffer: List[Dict[str, Any]] = []
    tagged_users_buffer: List[Dict[str, Any]] = []
    coauthor_producers_buffer: List[Dict[str, Any]] = []
    child_posts_relations: List[Dict[str, Any]] = []
    latest_comments_relations: List[Dict[str, Any]] = []
    post_tagged_users_relations: List[Dict[str, Any]] = []
    post_coauthor_producers_relations: List[Dict[str, Any]] = []

    # flatten all posts + relationships (including childPosts)
    for post in data:
        process_post_json(
            post,
            parent_post_instagram_id=None,
            posts_buffer=posts_buffer,
            comments_buffer=comments_buffer,
            tagged_users_buffer=tagged_users_buffer,
            coauthor_producers_buffer=coauthor_producers_buffer,
            child_posts_relations=child_posts_relations,
            latest_comments_relations=latest_comments_relations,
            post_tagged_users_relations=post_tagged_users_relations,
            post_coauthor_producers_relations=post_coauthor_producers_relations,
        )

    return {
        "posts": posts_buffer,
        "comments": comments_buffer,
        "tagged_users": tagged_users_buffer,
        "coauthor_producers": coauthor_producers_buffer,
        "child_posts_relations": child_posts_relations,
        "latest_comments_relations": latest_comments_relations,
        "post_tagged_users_relations": post_tagged_users_relations,
        "post_coauthor_producers_relations": post_coauthor_producers_relations,
    }


def upsert_instagram_data(data: List[Dict[str, Any]]) -> None:
    """
    data: list of top-level posts (like your big JSON above)

    Upserts into all n8n_ig schema tables with proper relationships.
    """
    supabase = get_supabase_client()

    # Process JSON into normalized structures
    processed_data = process_instagram_json(data)

    posts_buffer = processed_data["posts"]
    comments_buffer = processed_data["comments"]
    tagged_users_buffer = processed_data["tagged_users"]
    coauthor_producers_buffer = processed_data["coauthor_producers"]
    child_posts_relations = processed_data["child_posts_relations"]
    latest_comments_relations = processed_data["latest_comments_relations"]
    post_tagged_users_relations = processed_data["post_tagged_users_relations"]
    post_coauthor_producers_relations = processed_data["post_coauthor_producers_relations"]

    # --- STEP 1: Upsert posts ---
    if posts_buffer:
        print(f"Upserting {len(posts_buffer)} posts...")
        supabase.schema("n8n_ig").table("posts").upsert(
            posts_buffer,
            on_conflict="instagram_id"
        ).execute()

    # --- STEP 2: Upsert tagged users ---
    if tagged_users_buffer:
        # Deduplicate by instagram_id
        unique_tagged_users = {tu["instagram_id"]: tu for tu in tagged_users_buffer if tu.get("instagram_id")}
        print(f"Upserting {len(unique_tagged_users)} tagged users...")
        supabase.schema("n8n_ig").table("tagged_users").upsert(
            list(unique_tagged_users.values()),
            on_conflict="instagram_id"
        ).execute()

    # --- STEP 3: Upsert coauthor producers ---
    if coauthor_producers_buffer:
        # Deduplicate by instagram_id
        unique_coauthors = {cp["instagram_id"]: cp for cp in coauthor_producers_buffer if cp.get("instagram_id")}
        print(f"Upserting {len(unique_coauthors)} coauthor producers...")
        supabase.schema("n8n_ig").table("coauthor_producers").upsert(
            list(unique_coauthors.values()),
            on_conflict="instagram_id"
        ).execute()

    # --- STEP 4: Upsert comments ---
    if comments_buffer:
        print(f"Upserting {len(comments_buffer)} comments...")
        # First, get post IDs for the post_instagram_ids
        post_ids_map = {}
        for comment in comments_buffer:
            post_instagram_id = comment["post_instagram_id"]
            if post_instagram_id not in post_ids_map:
                result = supabase.schema("n8n_ig").table("posts").select("id").eq("instagram_id", post_instagram_id).execute()
                if result.data:
                    post_ids_map[post_instagram_id] = result.data[0]["id"]

        # Update comments with actual post_id
        for comment in comments_buffer:
            post_instagram_id = comment.pop("post_instagram_id")
            comment["post_id"] = post_ids_map.get(post_instagram_id)

        supabase.schema("n8n_ig").table("comments").upsert(
            comments_buffer,
            on_conflict="instagram_id"
        ).execute()

    # --- STEP 5: Create post-tagged_users relationships ---
    if post_tagged_users_relations:
        print(f"Creating {len(post_tagged_users_relations)} post-tagged_users relationships...")
        # Get post and tagged_user IDs
        relations_to_insert = []
        for rel in post_tagged_users_relations:
            post_result = supabase.schema("n8n_ig").table("posts").select("id").eq("instagram_id", rel["post_instagram_id"]).execute()
            tagged_user_result = supabase.schema("n8n_ig").table("tagged_users").select("id").eq("instagram_id", rel["tagged_user_instagram_id"]).execute()

            if post_result.data and tagged_user_result.data:
                relations_to_insert.append({
                    "post_id": post_result.data[0]["id"],
                    "tagged_user_id": tagged_user_result.data[0]["id"],
                })

        if relations_to_insert:
            supabase.schema("n8n_ig").table("post_tagged_users").upsert(
                relations_to_insert,
                on_conflict="post_id,tagged_user_id"
            ).execute()

    # --- STEP 6: Create post-coauthor_producers relationships ---
    if post_coauthor_producers_relations:
        print(f"Creating {len(post_coauthor_producers_relations)} post-coauthor relationships...")
        relations_to_insert = []
        for rel in post_coauthor_producers_relations:
            post_result = supabase.schema("n8n_ig").table("posts").select("id").eq("instagram_id", rel["post_instagram_id"]).execute()
            coauthor_result = supabase.schema("n8n_ig").table("coauthor_producers").select("id").eq("instagram_id", rel["coauthor_instagram_id"]).execute()

            if post_result.data and coauthor_result.data:
                relations_to_insert.append({
                    "post_id": post_result.data[0]["id"],
                    "coauthor_producer_id": coauthor_result.data[0]["id"],
                })

        if relations_to_insert:
            supabase.schema("n8n_ig").table("post_coauthor_producers").upsert(
                relations_to_insert,
                on_conflict="post_id,coauthor_producer_id"
            ).execute()

    # --- STEP 7: Create parent-child post relationships ---
    if child_posts_relations:
        print(f"Creating {len(child_posts_relations)} parent-child post relationships...")
        relations_to_insert = []
        for rel in child_posts_relations:
            parent_result = supabase.schema("n8n_ig").table("posts").select("id").eq("instagram_id", rel["parent_instagram_id"]).execute()
            child_result = supabase.schema("n8n_ig").table("posts").select("id").eq("instagram_id", rel["child_instagram_id"]).execute()

            if parent_result.data and child_result.data:
                relations_to_insert.append({
                    "parent_post_id": parent_result.data[0]["id"],
                    "child_post_id": child_result.data[0]["id"],
                    "position": rel["position"],
                })

        if relations_to_insert:
            supabase.schema("n8n_ig").table("post_child_posts").upsert(
                relations_to_insert,
                on_conflict="parent_post_id,child_post_id"
            ).execute()

    # --- STEP 8: Create post-latest_comments relationships ---
    if latest_comments_relations:
        print(f"Creating {len(latest_comments_relations)} post-latest_comments relationships...")
        relations_to_insert = []
        for rel in latest_comments_relations:
            post_result = supabase.schema("n8n_ig").table("posts").select("id").eq("instagram_id", rel["post_instagram_id"]).execute()
            comment_result = supabase.schema("n8n_ig").table("comments").select("id").eq("instagram_id", rel["comment_instagram_id"]).execute()

            if post_result.data and comment_result.data:
                relations_to_insert.append({
                    "post_id": post_result.data[0]["id"],
                    "comment_id": comment_result.data[0]["id"],
                    "position": rel["position"],
                })

        if relations_to_insert:
            supabase.schema("n8n_ig").table("post_latest_comments").upsert(
                relations_to_insert,
                on_conflict="post_id,comment_id"
            ).execute()

    print("Done.")


if __name__ == "__main__":
    # --- LOCAL TESTING SECTION ---
    #
    # Load JSON from file
    import sys

    json_file = sys.argv[1] if len(sys.argv) > 1 else "data/posts.json"

    with open(json_file, "r", encoding="utf-8") as f:
        instagram_json = json.load(f)

    upsert_instagram_data(instagram_json)
