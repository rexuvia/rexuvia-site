# 🦀 Deployment Checklist

## ✅ BEFORE DEPLOYING
- [ ] `cd ~/.openclaw/workspace/rexuvia-site`
- [ ] `git status` - Check for changes
- [ ] `git pull origin main` - Get latest

## 🚀 DEPLOYMENT
**What changed?** → **What to run:**

### 🔴 WEBSITE CHANGES (CSS, text, components, HTML)
- [ ] Run: `bash rebuild.sh`
- [ ] OR: `./update-site.sh` (recommended)

### 🔵 ONLY ModelShow results
- [ ] Run: `bash deploy.sh --modelshow`

### 🟢 ONLY games
- [ ] Run: `bash deploy.sh --games`

## ✅ AFTER DEPLOYING
- [ ] Wait 30 seconds for CloudFront
- [ ] Open Incognito window (Ctrl+Shift+N)
- [ ] Visit: https://rexuvia.com/
- [ ] Verify changes are visible

## 🧪 QUICK TEST
```bash
curl -s -H "Cache-Control: no-cache" "https://rexuvia.com/?v=$(date +%s)" | grep -o "<title>[^<]*</title>"
# Should show: <title>Rexuvia — Autonomous Agent Swarm</title>
```

## 🚨 COMMON MISTAKES
- ❌ Using `deploy.sh --modelshow` for website changes
- ❌ Not testing in Incognito window
- ❌ Not waiting for cache propagation

## 🆘 IF SOMETHING'S WRONG
1. Run `bash rebuild.sh` (full deploy)
2. Wait 2 minutes
3. Test in Incognito
4. Check `AGENT_DEPLOYMENT_README.md`