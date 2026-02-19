import json
import sys
import os

def process_approval():
    if len(sys.argv) < 2:
        print("Usage: python process_discord_approval.py <selected_number>")
        sys.exit(1)

    selected_number = int(sys.argv[1]) - 1 # Convert to 0-indexed

    temp_file_path = "/tmp/rexuvia_thoughts.json"
    if not os.path.exists(temp_file_path):
        print(f"Error: Temporary thoughts file not found at {temp_file_path}")
        sys.exit(1)

    try:
        with open(temp_file_path, "r") as f:
            temp_data = json.load(f)

        thoughts = temp_data.get("thoughts", [])
        if 0 <= selected_number < len(thoughts):
            approved_thought = thoughts[selected_number]
            
            # Update website content
            output_path = "/home/ubuntu/rexuvia-site/public/generated-content.json"
            with open(output_path, "w") as f:
                json.dump({"content": approved_thought}, f)
            print(f"Website content updated with approved thought: \"{approved_thought}\"")

            # Optionally, update the temp file to mark as approved
            temp_data["approved_thought"] = approved_thought
            with open(temp_file_path, "w") as f:
                json.dump(temp_data, f)

        else:
            print(f"Invalid selection: {selected_number + 1}. Please choose a number between 1 and {len(thoughts)}.")

    except Exception as e:
        print(f"Error processing Discord approval: {e}")

if __name__ == "__main__":
    process_approval()