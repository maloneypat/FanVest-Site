#!/bin/sh
set -eu

site_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
aasa="$site_root/.well-known/apple-app-site-association"
contest_html="$site_root/fantasy/contest/index.html"
profile_html="$site_root/fantasy/player-profile/index.html"
legacy_current_html="$site_root/fantasy/current-contest/index.html"
legacy_previous_html="$site_root/fantasy/previous-contests/index.html"
invite_html="$site_root/invite/index.html"
sitemap="$site_root/sitemap.xml"

fail() {
  echo "Share contract check failed: $1" >&2
  exit 1
}

/usr/bin/jq empty "$aasa"

for route in /fantasy/contest /fantasy/player-profile /fantasy/current-contest /fantasy/previous-contests; do
  grep -Fq "\"/\": \"$route\"" "$aasa" || fail "AASA route $route is missing"
done

grep -Fq 'original FanVest link' "$contest_html" || fail "contest install-return guidance is missing"
grep -Fq 'does not display contest picks' "$contest_html" || fail "contest privacy boundary is missing"
grep -Fq 'original message and tap the link again' "$profile_html" || fail "profile install-return guidance is missing"
grep -Fq 'does not display Apple account details' "$profile_html" || fail "profile privacy boundary is missing"
grep -Fq 'legacy contest link' "$legacy_current_html" || fail "legacy current-contest guidance is missing"
grep -Fq 'older messages' "$legacy_previous_html" || fail "legacy previous-contest guidance is missing"
grep -Fq 'name="robots" content="noindex,nofollow,noarchive"' "$invite_html" || fail "invite page must not be indexed"

grep -Fq 'https://fanvestapp.com/fantasy/contest' "$sitemap" || fail "contest page is missing from sitemap"
grep -Fq 'https://fanvestapp.com/fantasy/player-profile' "$sitemap" || fail "profile page is missing from sitemap"
if grep -Fq 'https://fanvestapp.com/invite' "$sitemap"; then
  fail "single-use invite route must not be in sitemap"
fi

for html in "$contest_html" "$profile_html"; do
  if grep -Eqi 'location\.search|URLSearchParams|contestUUID|playerUUID' "$html"; then
    fail "fallback pages must not render share identifiers"
  fi
done

echo "Share contract checks passed."
