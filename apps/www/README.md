# sak.coody.app

A Vite + React + Tailwind + [shadcn/ui](https://ui.shadcn.com) site, served as
static assets by its own Cloudflare Worker, **`coody-sak-www-prd-01`**, via
[Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/).

This is a separate Worker from `coody-sak-prd-01` (which serves
`coody.app/install.sh`) and from `coody-www-prd-01` (`www.coody.app`).

## Local development

```bash
pnpm install        # from the repo root
cd apps/www
pnpm run dev         # http://localhost:5173
```

## Deploy

```bash
npm install -g wrangler   # or use `npx wrangler` everywhere below
wrangler login              # authenticates against the Cloudflare account that owns coody.app

cd apps/www
pnpm run build               # outputs to dist/
wrangler deploy               # creates/updates coody-sak-www-prd-01 and publishes dist/
```

Or via Nx from the repo root: `npx nx run www:deploy` (runs `build` first).

`wrangler.toml` pins `account_id` to the `coody` Cloudflare account, so
`wrangler deploy` won't prompt you to pick an account.

After the first deploy, attach the **Custom Domain** `sak.coody.app` to this
Worker (Cloudflare dashboard → Workers & Pages → `coody-sak-www-prd-01` →
Settings → Domains & Routes → Add → Custom Domain). `sak.coody.app` has never
been configured before, so attaching it creates the needed DNS record
automatically — unlike the `coody.app` apex used by the other Worker, there's
no pre-existing record to conflict with.

## Verify

```bash
curl -sI https://sak.coody.app   # expect HTTP/2 200
```
