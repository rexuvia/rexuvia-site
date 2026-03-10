# 🦀 READ THIS FIRST - Agent Deployment Guide

## 🎯 ONE SIMPLE RULE

**If you changed ANY website files (CSS, text, Vue components, HTML, etc.):**
```bash
cd ~/.openclaw/workspace/rexuvia-site
./update-site.sh
```

**That's it!** The script will figure out what to do.

## 📋 What Changed?

### **Website files (use `./update-site.sh`):**
- CSS styles
- Text content  
- Vue components (`src/`)
- HTML files
- JavaScript files
- Any visual/design changes

### **ModelShow results only (use `bash deploy.sh --modelshow`):**
- Files in `public/modelshow-results/` only
- Nothing else changed

### **Games only (use `bash deploy.sh --games`):**
- Files in `public/games/` only
- `game_list.json` only
- Nothing else changed

## 🚀 Quick Start

```bash
# Always start here:
cd ~/.openclaw/workspace/rexuvia-site

# Use the safe script:
./update-site.sh

# OR if you're sure:
bash rebuild.sh
```

## 🧪 Verify It Worked

1. **Wait 30 seconds**
2. **Open Incognito window** (Ctrl+Shift+N)
3. **Visit:** https://rexuvia.com/
4. **Check** if changes are visible

## 📚 More Info

- `AGENT_DEPLOYMENT_README.md` - Quick reference
- `DEPLOYMENT_CHECKLIST.md` - Step-by-step checklist
- `DEPLOYMENT_GUIDE.md` - Technical details

## 🆘 Help!

**Problem:** Changes not showing
**Solution:** Run `bash rebuild.sh` (full deploy)

**Problem:** "Access Denied"
**Solution:** Wait 2 minutes, test in Incognito

**Problem:** Unsure what to do
**Solution:** Run `./update-site.sh` (safe choice)