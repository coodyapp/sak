# Serving install.sh from coody.app

This deploys a small Cloudflare Worker, **`coody-sak-prd-01`**, that
intercepts only `coody.app/install.sh` and proxies it from this repo's
`main` branch on GitHub. It is a separate Worker from the existing
`coody-www-prd-01` (which serves `www.coody.app`) and only ever attaches a
Route on the single path above — `coody-www-prd-01` and the rest of the zone
are untouched.

Prerequisite: `coody.app`'s nameservers must already point to Cloudflare
(true today). The zone also needs at least one DNS record for the bare
`coody.app` apex (proxied through Cloudflare) for this Route to ever receive
traffic — see the main README for the current status of that.

## Deploy

```bash
npm install -g wrangler   # or use `npx wrangler` everywhere below
wrangler login              # authenticates against the Cloudflare account that owns coody.app

cd cloudflare
wrangler deploy             # creates/updates coody-sak-prd-01 and attaches the Route from wrangler.toml
```

`wrangler.toml` pins `account_id` to the `coody` Cloudflare account, so
`wrangler deploy` won't prompt you to pick an account.

## Verify

1. Cloudflare dashboard → Workers & Pages → `coody-sak-prd-01` → Triggers →
   confirm `coody.app/install.sh` is listed under Routes.
2. `curl -sI https://coody.app/install.sh` → expect `HTTP/2 200` and
   `content-type: text/x-shellscript`.
3. On a Debian/Ubuntu machine: `curl -fsSL https://coody.app/install.sh | bash`
   (or `| bash -s -- install docker` to test argument passthrough).

## Updating install.sh

Because the Worker fetches `raw.githubusercontent.com/.../main/install.sh` on
every request (edge-cached 300s), pushing to `main` updates the live script
automatically. Re-run `wrangler deploy` only when `worker.js` or
`wrangler.toml` itself changes.
