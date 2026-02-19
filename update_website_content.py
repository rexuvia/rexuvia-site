import json
import sys

def update_content():
    if len(sys.argv) < 2:
        print("Usage: python update_website_content.py \"Your approved thought\"")
        sys.exit(1)

    approved_thought = sys.argv[1]
    output_path = "/home/ubuntu/rexuvia-site/public/generated-content.json"

    try:
        with open(output_path, "w") as f:
            json.dump({"content": approved_thought}, f)
        print(f"Website content updated with: \"{approved_thought}\"")
    except Exception as e:
        print(f"Error updating website content: {e}")

if __name__ == "__main__":
    update_content()