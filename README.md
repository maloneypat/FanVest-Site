# FanVest Site (GitHub Pages)

This is a minimal static site for FanVest. Replace placeholders and push to GitHub.

## Replace These
- **App Store ID** in `index.html` (search for `idYOUR_APP_ID`).
- **Support Email** in `index.html` (currently `support@fanvest.com`).
- **Domain** in `robots.txt` and `sitemap.xml` (replace `www.example.com`).

## Deploy
1. Create a repo (e.g., `fanvest-site`) and push these files.
2. In GitHub: Settings → Pages → Build from branch (main / root).
3. Add your custom domain in Settings → Pages (this creates/uses a `CNAME` file).
4. Update your DNS to point `A/AAAA` (apex) or `CNAME` (www) to GitHub Pages.
5. Enable **Enforce HTTPS** after the cert is issued.
