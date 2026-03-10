#!/bin/bash
# ========================================
# Rexuvia Site — Build, Sync & Deploy
# ========================================
# 🚨 WARNING: Read AGENT_DEPLOYMENT_README.md before using!
# 
# For website changes (CSS, text, components, HTML): Use ./update-site.sh or bash rebuild.sh
# DO NOT use --modelshow or --games for website changes!
#
# Usage:
#   ./deploy.sh              Full build + sync + invalidate (use for website changes)
#   ./deploy.sh --games      Sync games + game_list.json only (no rebuild)
#   ./deploy.sh --modelshow  Sync modelshow-results only (no rebuild)
#
# Requirements:
#   - AWS CLI configured (via EC2 instance role or credentials)
#   - Node.js + npm (for builds)

set -euo pipefail

BUCKET="rexuvia-site"
CF_DIST_ID="E1XVGZVNUPVUXK"
SITE_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$SITE_DIR/dist"
REGION="us-east-1"

cd "$SITE_DIR"

sync_hashed_assets() {
    aws s3 sync "$DIST_DIR/" "s3://$BUCKET/" --delete \
        --exclude "*.html" --exclude "*.json" --exclude "*.md" \
        --cache-control "public,max-age=31536000,immutable" \
        --region "$REGION"
}

sync_html_and_json() {
    aws s3 sync "$DIST_DIR/" "s3://$BUCKET/" \
        --exclude "*" --include "*.html" --include "*.json" --include "*.md" \
        --cache-control "no-cache" \
        --region "$REGION"
}

invalidate_cache() {
    local paths="${1:-/*}"
    echo "Invalidating CloudFront cache: $paths"
    aws cloudfront create-invalidation \
        --distribution-id "$CF_DIST_ID" \
        --paths "$paths" \
        --region "$REGION" \
        --query 'Invalidation.Id' --output text
}

case "${1:-}" in
    --games)
        echo "=== Games-only sync ==="
        aws s3 sync "$DIST_DIR/games/" "s3://$BUCKET/games/" \
            --cache-control "no-cache" --region "$REGION"
        aws s3 cp "$DIST_DIR/game_list.json" "s3://$BUCKET/game_list.json" \
            --cache-control "no-cache" --region "$REGION" 2>/dev/null || true
        invalidate_cache "/games/* /game_list.json"
        echo "Games sync complete."
        ;;
    --modelshow)
        echo "=== ModelShow results sync ==="
        aws s3 sync "$DIST_DIR/modelshow-results/" "s3://$BUCKET/modelshow-results/" \
            --cache-control "no-cache" --region "$REGION"
        invalidate_cache "/modelshow-results/*"
        echo "ModelShow sync complete."
        ;;
    *)
        echo "=== Full build + deploy ==="
        echo "Building site..."
        rm -rf "$DIST_DIR"
        npm run build 2>&1

        echo ""
        echo "Syncing hashed assets to S3..."
        sync_hashed_assets

        echo ""
        echo "Syncing HTML + JSON to S3..."
        sync_html_and_json

        echo ""
        INVID=$(invalidate_cache "/*")
        echo "Invalidation: $INVID"
        echo ""
        echo "Deploy complete."
        ;;
esac
