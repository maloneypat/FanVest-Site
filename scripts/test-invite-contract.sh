#!/bin/sh
set -eu

site_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
invite_html="$site_root/invite/index.html"
invite_script="$site_root/invite/invite.js"
contract="$site_root/invite/contract.json"
aasa="$site_root/.well-known/apple-app-site-association"

fail() {
  echo "Invite contract check failed: $1" >&2
  exit 1
}

/usr/bin/jq empty "$contract"
/usr/bin/jq empty "$aasa"

grep -Fq '"version": 1' "$contract" || fail "contract version is not 1"
grep -Fq '"path": "/invite"' "$contract" || fail "contract path is missing"
grep -Fq '"fragmentKey": "invite"' "$contract" || fail "fragment key is missing"
grep -Fq '"tokenPattern": "^[A-Za-z0-9_-]{43}$"' "$contract" || fail "token pattern changed"
grep -Fq '"appID": "J464NUJUFQ.com.PatMaloney.FanVest"' "$contract" || fail "app ID changed"
grep -Fq '"appStoreID": "6743630515"' "$contract" || fail "App Store ID changed"

grep -Fq '"appIDs": ["J464NUJUFQ.com.PatMaloney.FanVest"]' "$aasa" || fail "AASA app ID changed"
grep -Fq '"/": "/invite"' "$aasa" || fail "AASA /invite path is missing"
grep -Fq '"/": "/invite/*"' "$aasa" || fail "AASA /invite/* path is missing"

grep -Fq 'name="referrer" content="no-referrer"' "$invite_html" || fail "no-referrer policy is missing"
grep -Fq 'http-equiv="Cache-Control" content="no-store"' "$invite_html" || fail "no-store policy is missing"
grep -Fq "connect-src 'none'" "$invite_html" || fail "invite-page connections are not disabled"
grep -Fq 'return to the original invitation in Messages' "$invite_html" ||
  fail "post-install Messages guidance is missing"
grep -Fq 'href="https://fanvestapp.com/download/friend-invite"' "$invite_html" ||
  fail "Friend Invite campaign route changed"
grep -Fq 'src="/invite/invite.js?v=1"' "$invite_html" || fail "versioned invitation script is missing"
grep -Fq 'window.location.hash' "$invite_script" || fail "fragment parser is missing"
grep -Fq '/^[A-Za-z0-9_-]{43}$/' "$invite_script" || fail "browser token validation changed"
grep -Fq "addEventListener('hashchange'" "$invite_script" || fail "fragment navigation refresh is missing"

if grep -Eqi 'friend[ -]?code|inviteToken|location\.search|friend-invite\?token|fanvest://friend-invite' \
  "$invite_html" "$invite_script"; then
  fail "legacy Friend Code or query/custom-scheme transport remains"
fi

if grep -Eqi 'fetch\(|XMLHttpRequest|sendBeacon|localStorage|sessionStorage|document\.cookie' "$invite_script"; then
  fail "invite secret could leave transient fragment-only memory"
fi

echo "Invite contract checks passed."
