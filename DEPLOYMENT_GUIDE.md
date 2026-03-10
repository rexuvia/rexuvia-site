# Rexuvia.com Deployment Guide

## 🚨 CRITICAL: Deployment Workflow

### **When to use which command:**

| Command | When to use | What it does |
|---------|-------------|--------------|
| `bash rebuild.sh` | **ANY changes to website** (CSS, text, components, HTML, etc.) | 1. Updates ModelShow index<br>2. Rebuilds site (`npm run build`)<br>3. Deploys everything to S3/CloudFront |
| `bash deploy.sh` | Same as above (alternative) | Full rebuild + deploy (same as `rebuild.sh`) |
| `bash deploy.sh --modelshow` | **ONLY ModelShow results changed** | Syncs only `modelshow-results/` folder |
| `bash deploy.sh --games` | **ONLY games changed** | Syncs only `games/` folder and `game_list.json` |

## 🎯 **Common Errors & Prevention**

### **Error 1: CSS/Text updates not showing**
**Cause:** Ran `deploy.sh --modelshow` instead of full deploy
**Fix:** Always use `bash rebuild.sh` for website changes
**Check:** Verify HTML references correct CSS/JS hashes:
```bash
# Local vs S3 comparison
grep -o "index-[^.]*\.[a-z]*" dist/index.html
aws s3 cp s3://rexuvia-site/index.html - 2>/dev/null | grep -o "index-[^.]*\.[a-z]*"
```

### **Error 2: "Access Denied" on website**
**Cause:** CloudFront cache serving stale error
**Fix:** Wait 1-2 minutes after deploy, clear browser cache
**Check:** 
```bash
curl -I https://rexuvia.com/  # Should return 200
aws cloudfront list-invalidations --distribution-id E1XVGZVNUPVUXK
```

### **Error 3: Old content still showing**
**Cause:** Browser cache or CloudFront cache
**Fix:** Test in Incognito window, force cache invalidation
**Check:**
```bash
# Force fresh request
curl -s -H "Cache-Control: no-cache" "https://rexuvia.com/?v=$(date +%s)"
```

## 📋 **Deployment Checklist**

### **Before Deploying:**
1. ✅ `git status` - Check for uncommitted changes
2. ✅ `git pull origin main` - Get latest changes
3. ✅ Verify changes in source files

### **Deployment Command:**
```bash
# For website changes (CSS, text, components, etc.):
bash rebuild.sh

# OR
bash deploy.sh

# For specific changes only:
bash deploy.sh --modelshow   # ModelShow results only
bash deploy.sh --games       # Games only
```

### **After Deploying:**
1. ✅ Wait 30 seconds for CloudFront propagation
2. ✅ Verify in Incognito browser window
3. ✅ Check key pages:
   ```bash
   curl -s -H "Cache-Control: no-cache" "https://rexuvia.com/"
   curl -s -H "Cache-Control: no-cache" "https://rexuvia.com/modelshow-results/index.json"
   ```

## 🔧 **Technical Details**

### **Build Process:**
```
Source files (Vue components, HTML, etc.)
    ↓
Vite build (npm run build)
    ↓
dist/ folder with hashed assets
    ↓
S3 sync (deploy.sh)
    ↓
CloudFront cache invalidation
```

### **File Hashing:**
- CSS/JS files get content-based hashes: `index-ABC123.css`
- HTML references these hashes
- **If CSS/JS content changes → new hash → HTML must be updated**

### **Cache Strategy:**
- **HTML/JSON/MD:** `Cache-Control: no-cache`
- **Assets (CSS/JS/images):** `Cache-Control: public,max-age=31536000,immutable`
- CloudFront TTL overrides may apply

## 🚀 **Quick Reference Scripts**

### **update-site.sh** (Recommended)
```bash
#!/bin/bash
# Complete website update
cd ~/.openclaw/workspace/rexuvia-site
git pull origin main
bash rebuild.sh
echo "Deployment complete. Test in Incognito window."
```

### **verify-deployment.sh**
```bash
#!/bin/bash
# Verify deployment worked
echo "=== Verifying Deployment ==="
echo "1. S3 files:"
aws s3 ls s3://rexuvia-site/assets/ | grep "index-"
echo ""
echo "2. Live site (cache busted):"
curl -s -H "Cache-Control: no-cache" "https://rexuvia.com/?v=$(date +%s)" | grep -o "<title>[^<]*</title>"
echo ""
echo "3. ModelShow index:"
curl -s -H "Cache-Control: no-cache" "https://rexuvia.com/modelshow-results/index.json" | head -3
```

## 🆘 **Emergency Recovery**

### **If site shows wrong content:**
```bash
# 1. Force full rebuild and deploy
cd ~/.openclaw/workspace/rexuvia-site
rm -rf dist node_modules/.vite
bash rebuild.sh

# 2. Force CloudFront cache clear
aws cloudfront create-invalidation --distribution-id E1XVGZVNUPVUXK --paths "/*"

# 3. Wait and test
sleep 60
curl -s -H "Cache-Control: no-cache" "https://rexuvia.com/"
```

### **If "Access Denied" persists:**
1. Check S3 bucket policy (should allow public read)
2. Check CloudFront Origin Access Identity
3. Verify IAM permissions for EC2 instance

## 📞 **Debugging Commands**

```bash
# Check what's deployed vs local
diff -u <(aws s3 cp s3://rexuvia-site/index.html - 2>/dev/null) dist/index.html

# Check CloudFront invalidations
aws cloudfront list-invalidations --distribution-id E1XVGZVNUPVUXK

# Check S3 file sizes/timestamps
aws s3 ls s3://rexuvia-site/ --recursive | sort -k1,2

# Test from different regions (bypass local cache)
curl -s "https://rexuvia.com/?$(date +%s)"
```

## 🎯 **Golden Rule**

**For ANY website changes (CSS, text, components, HTML):**
```bash
bash rebuild.sh
```

**NOT:**
```bash
bash deploy.sh --modelshow  # ❌ Only for ModelShow results
```

**Exception:** Only use `--modelshow` or `--games` when you're 100% sure only those specific files changed.