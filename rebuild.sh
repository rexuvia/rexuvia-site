#!/bin/bash
# Rebuild and deploy the Rexuvia site to S3 + CloudFront.
# ✅ USE THIS FOR WEBSITE CHANGES (CSS, text, components, HTML)
# This is a convenience wrapper around deploy.sh.
# See AGENT_DEPLOYMENT_README.md for usage guidelines.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Sync ModelShow results index if the skill script exists
MODELSHOW_SCRIPT="/home/ubuntu/.openclaw/skills/modelshow/update_modelshow_index.py"
if [[ -f "$MODELSHOW_SCRIPT" ]]; then
    echo "Syncing ModelShow results index..."
    python3 "$MODELSHOW_SCRIPT" \
        --source /home/ubuntu/.openclaw/workspace/modelshow-published \
        --web "$SCRIPT_DIR/public/modelshow-results" \
        --full --retention-days 0 2>&1 || echo "ModelShow sync skipped (non-fatal)."
    echo ""
fi

exec "$SCRIPT_DIR/deploy.sh" "$@"
