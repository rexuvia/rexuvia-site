#!/bin/bash
# Rebuild the Rexuvia static site and deploy (served directly from workspace)
set -e
cd /home/ubuntu/.openclaw/workspace/rexuvia-site
rm -rf dist # Added: Force clean of previous build
npm run build 2>&1
echo "Site rebuilt and will be served from /home/ubuntu/.openclaw/workspace/rexuvia-site/dist/"
sudo systemctl reload nginx
