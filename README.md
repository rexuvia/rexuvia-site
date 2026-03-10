# Rexuvia Site

Public website for [rexuvia.com](https://rexuvia.com), served via **S3 + CloudFront**.

## Architecture

- **Hosting:** S3 bucket `rexuvia-site` behind CloudFront distribution `E1XVGZVNUPVUXK`
- **SSL:** ACM wildcard certificate (`*.rexuvia.com` + `rexuvia.com`)
- **Build:** Vite + Vue 3 + UnoCSS
- **Source location:** `/home/ubuntu/.openclaw/workspace/rexuvia-site/`

## Directory Structure

```
rexuvia-site/
├── deploy.sh                  # Main deploy script (build + S3 sync + invalidate)
├── rebuild.sh                 # Wrapper: syncs ModelShow index then runs deploy.sh
├── package.json               # Node dependencies
├── vite.config.js             # Vite build config
├── uno.config.js              # UnoCSS config
├── index.html                 # Vite HTML entry point
├── src/
│   ├── App.vue                # Main Vue component (all page sections)
│   ├── main.js                # Vue app bootstrap
│   ├── assets/                # Images (rexuvia.png, rexuvia.webp)
│   └── components/
│       ├── RexuviaLogo.vue    # Logo component
│       └── ModelShowResults.vue # Model comparison table component
└── public/
    ├── favicon.svg
    ├── game_list.json          # Game catalog (drives the "Web Apps" tab)
    ├── games/                  # Self-contained game/app HTML files
    ├── game/                   # Legacy game entry point
    └── modelshow-results/      # Model comparison results (JSON + MD pairs)
        └── index.json          # Index of all published comparisons
```

## How to Deploy

### Full deploy (build + sync + invalidate)

```bash
./deploy.sh
```

This runs `npm run build`, syncs `dist/` to S3 with appropriate cache headers,
and creates a CloudFront cache invalidation.

### Games-only sync (no rebuild needed)

```bash
./deploy.sh --games
```

Syncs the `games/` directory and `game_list.json` to S3.

### ModelShow results sync (no rebuild needed)

```bash
./deploy.sh --modelshow
```

Syncs the `modelshow-results/` directory to S3.

### Full rebuild with ModelShow index update

```bash
./rebuild.sh
```

Runs the ModelShow index sync script (if available), then a full deploy.

## How to Add a New Game / Web App

1. Create a **self-contained HTML file** in `public/games/`. Include all CSS and JS
   inline — no external dependencies. Name it descriptively, e.g.
   `public/games/my-new-game.html`.

2. Add an entry to `public/game_list.json`:
   ```json
   {
     "title": "My New Game",
     "url": "/games/my-new-game.html",
     "github_url": "https://github.com/rexuvia/my-new-game",
     "date": "2026-03-06",
     "last_updated": "2026-03-06"
   }
   ```
   Games appear on the homepage in the order listed in this file.

3. Deploy:
   ```bash
   ./deploy.sh --games
   ```
   Or do a full deploy with `./deploy.sh` if you also changed Vue source files.

## How to Add Model Comparison Results

Model comparison results live in `public/modelshow-results/`. Each result is a pair
of files: a `.json` (structured data for the table) and a `.md` (human-readable summary).

1. Place the `.json` and `.md` files in `public/modelshow-results/`. The naming
   convention is: `<slug>-<date>-<time>.json` and `.md`.

2. Update `public/modelshow-results/index.json` to include the new entry. This index
   drives the model comparison table on the site. The `update_modelshow_index.py`
   skill script can do this automatically:
   ```bash
   python3 /home/ubuntu/.openclaw/skills/modelshow/update_modelshow_index.py \
     --source /home/ubuntu/.openclaw/workspace/modelshow-published \
     --web /home/ubuntu/.openclaw/workspace/rexuvia-site/public/modelshow-results \
     --full --retention-days 0
   ```
   Or use `./rebuild.sh` which runs this automatically before deploying.

3. Deploy:
   ```bash
   ./deploy.sh --modelshow
   ```
   Or `./rebuild.sh` for a full rebuild with index sync.

## How to Publish Content to a Subdomain

S3 buckets exist for these subdomains (all currently showing placeholder pages):

| Subdomain | S3 Bucket | Purpose |
|-----------|-----------|---------|
| `api.rexuvia.com` | `rexuvia-api` | API documentation |
| `dashboard.rexuvia.com` | `rexuvia-dashboard` | Dashboard |
| `admin.rexuvia.com` | `rexuvia-admin` | Admin panel |
| `apps.rexuvia.com` | `rexuvia-apps` | Mini-applications |
| `blog.rexuvia.com` | `rexuvia-blog` | Blog/articles |
| `docs.rexuvia.com` | `rexuvia-docs` | Documentation |
| `lab.rexuvia.com` | `rexuvia-lab` | Experiments/sandbox |

To publish content to a subdomain:

1. Upload files to the bucket:
   ```bash
   aws s3 sync ./my-content/ s3://rexuvia-blog/ --delete
   ```

2. A CloudFront distribution and DNS record will need to be created for the subdomain
   when it's first activated. The ACM wildcard cert already covers all subdomains.

## S3 and CloudFront Details

- **S3 Bucket:** `rexuvia-site` (us-east-1)
- **CloudFront Distribution:** `E1XVGZVNUPVUXK`
- **CloudFront Domain:** `d2ah8bvnemccat.cloudfront.net`
- **ACM Certificate:** Wildcard `*.rexuvia.com` + `rexuvia.com`
- **Cache Policy:** Hashed assets (CSS/JS) cached for 1 year; HTML, JSON, and MD
  served with `no-cache` so updates appear immediately after invalidation.
- **SPA Routing:** CloudFront returns `index.html` for 403/404 responses so Vue
  Router works on all paths.
