"""
Example script demonstrating how to use the process_instagram_json() function
for processing Instagram data without upserting to Supabase.

This can be useful for:
- Validating data before insertion
- Transforming data for other purposes
- Analyzing data structure
- Exporting to other formats
"""

import json
from upsert_posts import process_instagram_json


def main():
    # Example 1: Load and process JSON
    with open("data/posts.json", "r", encoding="utf-8") as f:
        instagram_json = json.load(f)

    # Process the JSON without database operations
    processed_data = process_instagram_json(instagram_json)

    # Now you can do whatever you want with the processed data
    print(f"Processed {len(processed_data['posts'])} posts")
    print(f"Processed {len(processed_data['comments'])} comments")
    print(f"Processed {len(processed_data['tagged_users'])} tagged users")
    print(f"Processed {len(processed_data['coauthor_producers'])} coauthor producers")

    # Example 2: Export to different format
    # You could save to CSV, send to another API, etc.
    with open("output/processed_posts.json", "w", encoding="utf-8") as f:
        json.dump(processed_data, f, indent=2, default=str)

    # Example 3: Analyze data
    post_types = {}
    for post in processed_data["posts"]:
        post_type = post.get("type", "Unknown")
        post_types[post_type] = post_types.get(post_type, 0) + 1

    print("\nPost types distribution:")
    for post_type, count in post_types.items():
        print(f"  {post_type}: {count}")


if __name__ == "__main__":
    main()
