#!/bin/bash
# update-site.sh - Safe website update script
# Use this for ANY website changes (CSS, text, components, etc.)

set -euo pipefail

echo "=== Rexuvia Site Update ==="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -f "deploy.sh" ]; then
    echo "❌ Error: Must run from rexuvia-site directory"
    echo "cd ~/.openclaw/workspace/rexuvia-site"
    exit 1
fi

# Check for uncommitted changes
if [ -d ".git" ]; then
    echo "📊 Checking git status..."
    if ! git diff --quiet; then
        echo "⚠️  Warning: Uncommitted changes detected"
        echo "   Consider: git add . && git commit -m 'Your message'"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

# Determine what changed
echo "🔍 Detecting changes..."
CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || echo "")

if echo "$CHANGED_FILES" | grep -q -E "\.(vue|css|js|html|json)$" && \
   ! echo "$CHANGED_FILES" | grep -q "^public/modelshow-results/" && \
   ! echo "$CHANGED_FILES" | grep -q "^public/games/"; then
    echo "📝 Website source files changed - full rebuild needed"
    DEPLOY_MODE="full"
elif echo "$CHANGED_FILES" | grep -q "^public/modelshow-results/"; then
    echo "📊 ModelShow results changed - partial deploy"
    DEPLOY_MODE="modelshow"
elif echo "$CHANGED_FILES" | grep -q "^public/games/"; then
    echo "🎮 Games changed - partial deploy"
    DEPLOY_MODE="games"
else
    echo "❓ Unknown changes - defaulting to full rebuild"
    DEPLOY_MODE="full"
fi

# Run appropriate deploy
echo ""
echo "🚀 Deploying..."
case "$DEPLOY_MODE" in
    "full")
        echo "Running: bash rebuild.sh"
        bash rebuild.sh
        ;;
    "modelshow")
        echo "Running: bash deploy.sh --modelshow"
        bash deploy.sh --modelshow
        ;;
    "games")
        echo "Running: bash deploy.sh --games"
        bash deploy.sh --games
        ;;
    *)
        echo "Running: bash rebuild.sh (default)"
        bash rebuild.sh
        ;;
esac

# Verification
echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Verification steps:"
echo "1. Wait 30 seconds for CloudFront propagation"
echo "2. Test in Incognito browser window"
echo "3. Check: https://rexuvia.com/"
echo ""
echo "🔄 Quick test command:"
echo "curl -s -H 'Cache-Control: no-cache' 'https://rexuvia.com/?v=\$(date +%s)' | grep -o '<title>[^<]*</title>'"