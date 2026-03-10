# 🦀 Agent Deployment Instructions

## 🚨 ONE RULE TO REMEMBER

**If you change ANY website files (CSS, text, Vue components, HTML, etc.):**
```bash
cd ~/.openclaw/workspace/rexuvia-site
bash rebuild.sh
```

**DO NOT use `deploy.sh --modelshow` for website changes!**

## 📋 Quick Decision Guide

### **What changed? → What to run:**

| Changes | Command |
|---------|---------|
| **CSS, text, Vue components, HTML** | `bash rebuild.sh` |
| **Only ModelShow results** (`public/modelshow-results/`) | `bash deploy.sh --modelshow` |
| **Only games** (`public/games/`) | `bash deploy.sh --games` |
| **Unsure / mixed changes** | `bash rebuild.sh` |

## 🛠️ Recommended Workflow

### **Use the safe script:**
```bash
cd ~/.openclaw/workspace/rexuvia-site
./update-site.sh
```

This script:
1. Checks what changed
2. Runs the correct deploy command
3. Provides verification steps

## 🔍 How to Verify Deployment Worked

### **Immediate check (command line):**
```bash
# Cache-busted request
curl -s -H "Cache-Control: no-cache" "https://rexuvia.com/?v=$(date +%s)" | grep -o "<title>[^<]*</title>"

# Should show: <title>Rexuvia — Autonomous Agent Swarm</title>
```

### **Browser check:**
1. Open **Incognito window** (Ctrl+Shift+N)
2. Go to `https://rexuvia.com/`
3. Check if changes are visible

## 🚑 Common Problems & Fixes

### **Problem: Changes not showing**
**Likely cause:** Ran `deploy.sh --modelshow` instead of `rebuild.sh`
**Fix:** Run `bash rebuild.sh`

### **Problem: "Access Denied"**
**Likely cause:** CloudFront cache issue
**Fix:** Wait 1-2 minutes, clear browser cache, test in Incognito

### **Problem: Wrong CSS/JS version**
**Likely cause:** HTML references old file hashes
**Fix:** Run `bash rebuild.sh` (updates all files)

## 📊 Technical Notes for Agents

### **How the build works:**
1. Vue components → Vite build → `dist/` folder
2. CSS/JS get content-based hashes: `index-ABC123.css`
3. HTML references these hashes
4. **If CSS/JS changes → new hash → HTML must update**

### **Why `deploy.sh --modelshow` fails for website changes:**
- Only syncs `modelshow-results/` folder
- Doesn't rebuild site
- Doesn't update HTML/CSS/JS
- HTML still references old CSS/JS hashes

## 🎯 Simple Summary

**For agents:** Always use `./update-site.sh` or `bash rebuild.sh`

**Only use `deploy.sh --modelshow` if you're 100% sure you only updated ModelShow results files in `public/modelshow-results/`**

**When in doubt:** `bash rebuild.sh`