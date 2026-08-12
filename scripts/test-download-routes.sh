#!/bin/sh
set -eu

site_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
aasa="$site_root/.well-known/apple-app-site-association"
sitemap="$site_root/sitemap.xml"
app_id="6743630515"
provider_token="127713908"

fail() {
  echo "Download route check failed: $1" >&2
  exit 1
}

check_route() {
  route=$1
  campaign=$2
  page="$site_root/download/$route/index.html"

  test -f "$page" || fail "/download/$route is missing"
  grep -Fq 'name="robots" content="noindex,nofollow,noarchive"' "$page" ||
    fail "/download/$route must not be indexed"
  grep -Fq 'name="referrer" content="no-referrer"' "$page" ||
    fail "/download/$route must suppress referrers"
  grep -Fq "id$app_id?pt=$provider_token&amp;ct=$campaign&amp;mt=8" "$page" ||
    fail "/download/$route has the wrong Apple campaign destination"
  grep -Fq 'Continue to the App Store' "$page" ||
    fail "/download/$route is missing its manual fallback"
  if grep -Eqi 'fetch\(|XMLHttpRequest|sendBeacon|localStorage|sessionStorage|document\.cookie|<script' "$page"; then
    fail "/download/$route must not collect or transmit browser data"
  fi
}

check_route instagram 'Instagram%20Organic'
check_route facebook 'Facebook%20Organic'
check_route x 'X%20Organic'
check_route website 'Website%20Organic'
check_route in-app-share 'In%20App%20Share'
check_route friend-invite 'Friend%20Invite'

if grep -Fq '"/": "/download' "$aasa"; then
  fail "download routes must not be Universal Link destinations"
fi

if grep -Fq 'https://fanvestapp.com/download/' "$sitemap"; then
  fail "download routes must not be listed in the sitemap"
fi

grep -Fq 'href="https://fanvestapp.com/download/website"' "$site_root/index.html" ||
  fail "homepage does not use Website Organic"

for page in \
  "$site_root/fantasy/contest/index.html" \
  "$site_root/fantasy/current-contest/index.html" \
  "$site_root/fantasy/previous-contests/index.html" \
  "$site_root/fantasy/player-profile/index.html"; do
  grep -Fq 'href="https://fanvestapp.com/download/in-app-share"' "$page" ||
    fail "$(basename "$(dirname "$page")") does not use In App Share"
done

grep -Fq 'href="https://fanvestapp.com/download/friend-invite"' "$site_root/invite/index.html" ||
  fail "invite page does not use Friend Invite"

echo "Download route checks passed."
