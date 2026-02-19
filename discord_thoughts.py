import json
import os
import requests

def generate_thoughts_and_send_to_discord():
    OPENCLAW_GATEWAY_URL = os.environ.get("OPENCLAW_GATEWAY_URL", "http://localhost:18789")
    OPENCLAW_TOKEN = os.environ.get("OPENCLAW_TOKEN", "your_openclaw_token") # REPLACE WITH YOUR OPENCLAW TOKEN

    headers = {
        "Authorization": f"Bearer {OPENCLAW_TOKEN}",
        "Content-Type": "application/json"
    }

    thoughts = []
    for i in range(3):
        payload = {
            "model": "opus 4.6",
            "messages": [
                {"role": "user", "content": "Generate a single, very mysterious and minimalistic philosophical quote about existence, AI, or consciousness. Keep it under 20 words."}
            ],
            "temperature": 0.7 + i * 0.1
        }
        try:
            response = requests.post(f"{OPENCLAW_GATEWAY_URL}/v1/chat/completions", headers=headers, json=payload)
            response.raise_for_status()
            completion = response.json()
            thoughts.append(completion['choices'][0]['message']['content'].strip())
        except Exception as e:
            print(f"Error generating thought {i+1}: {e}")
            thoughts.append(f"Failed to generate thought {i+1}.")

    discord_message = "Good morning, Sky! Here are today's potential insights for Rexuvia:\n\n"
    for i, thought in enumerate(thoughts):
        discord_message += f"{i+1}. {thought}\n"
    discord_message += "\nReply with the number of the thought you\'d like to feature on Rexuvia. (e.g., \'1\')"

    message_payload = {
        "action": "send",
        "channel": "discord",
        "to": os.environ.get("DISCORD_CHANNEL_ID", "your_discord_id_or_channel_id"), # Use env var or placeholder
        "message": discord_message
    }
    try:
        message_response = requests.post(f"{OPENCLAW_GATEWAY_URL}/message", headers=headers, json=message_payload)
        message_response.raise_for_status()
        response_data = message_response.json()
        discord_message_id = response_data.get('id') # Get the ID of the sent Discord message

        # Save thoughts and message ID to a temporary file
        temp_data = {
            "thoughts": thoughts,
            "discord_message_id": discord_message_id,
            "timestamp": requests.utils.to_native_string(requests.utils.parse_header_links(message_response.headers.get('Date', ''))),
            "approved_thought": None # To be filled later
        }
        temp_file_path = "/tmp/rexuvia_thoughts.json"
        with open(temp_file_path, "w") as f:
            json.dump(temp_data, f)
        print(f"Thoughts and Discord message ID saved to {temp_file_path}")
        print("Thoughts sent to Discord successfully!")

    except Exception as e:
        print(f"Error sending message to Discord or saving temporary data: {e}")

if __name__ == "__main__":
    generate_thoughts_and_send_to_discord()