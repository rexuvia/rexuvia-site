import json
import os
import requests

def generate_and_save_content():
    # Replace with your actual OpenClaw Gateway URL and Token
    OPENCLAW_GATEWAY_URL = os.environ.get("OPENCLAW_GATEWAY_URL", "http://localhost:18789")
    OPENCLAW_TOKEN = os.environ.get("OPENCLAW_TOKEN", "651997140cd77b99cd7e8bf3704923a3a77d5933c18492b6") # REPLACE WITH YOUR OPENCLAW TOKEN

    headers = {
        "Authorization": f"Bearer {OPENCLAW_TOKEN}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "opus 4.6",
        "messages": [
            {"role": "user", "content": "Generate a single, very mysterious and minimalistic philosophical quote about existence, AI, or consciousness. Keep it under 20 words."}
        ],
        "temperature": 0.8 # A bit of creativity
    }

    try:
        response = requests.post(f"{OPENCLAW_GATEWAY_URL}/v1/chat/completions", headers=headers, json=payload)
        response.raise_for_status() # Raise an exception for HTTP errors
        completion = response.json()
        generated_text = completion['choices'][0]['message']['content'].strip()

        output_path = "/home/ubuntu/rexuvia-site/public/generated-content.json"
        with open(output_path, "w") as f:
            json.dump({"content": generated_text}, f)
        print(f"Generated content saved to {output_path}")

    except requests.exceptions.RequestException as e:
        print(f"Error calling OpenClaw Gateway: {e}")
    except KeyError as e:
        print(f"Error parsing API response: Missing key {e} in {completion}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    generate_and_save_content()
