# Serving entrypoint.sh from coody.app

This deploys a small Cloudflare Worker that intercepts only `coody.app/entrypoint.sh`
and proxies it from this repo's `main` branch on GitHub. Every other request
to `coody.app` (the existing website, in its own repo) is untouched — the
Worker Route only matches that one path.

Prerequisite: `coody.app`'s nameservers must already point to Cloudflare
(true today). No DNS records need to change for this to work.

## Deploy

```bash
npm install -g wrangler   # or use `npx wrangler` everywhere below
wrangler login             # authenticates against the Cloudflare account that owns coody.app

cd cloudflare
wrangler deploy            # creates/updates the Worker and attaches the Route from wrangler.toml
```

## Verify

1. Cloudflare dashboard → Workers & Pages → `sak-installer` → Triggers →
   confirm `coody.app/entrypoint.sh` is listed under Routes.
2. `curl -sI https://coody.app/entrypoint.sh` → expect `HTTP/2 200` and
   `content-type: text/x-shellscript`.
3. On a Debian/Ubuntu machine: `curl -fsSL https://coody.app/entrypoint.sh | bash`
   (or `| bash -s -- install docker` to test argument passthrough).

## Updating entrypoint.sh

Because the Worker fetches `raw.githubusercontent.com/.../main/entrypoint.sh` on
every request (edge-cached 300s), pushing to `main` updates the live script
automatically. Re-run `wrangler deploy` only when `worker.js` or
`wrangler.toml` itself changes.
