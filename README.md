# sak

A Swiss Army Knife that installs the tools you actually use, with a single
command:

```bash
curl -fsSL https://coody.app/install.sh | bash
```

This installs the `sak` CLI to `~/.sak` and adds it to your `PATH`. You can
also install a tool directly in one shot:

```bash
curl -fsSL https://coody.app/install.sh | bash -s -- install docker
```

Currently supported: **Debian-based Linux only** (Ubuntu, Debian, etc).
Other operating systems are coming soon.

## Usage

```bash
sak list              # see available tools
sak install <tool>    # install one, e.g. `sak install docker`
sak update             # pull the latest sak + tool scripts
sak version
```

## Adding a tool

Drop a self-contained, idempotent script at `src/<tool>/setup.sh`. It will
show up automatically in `sak list` and run via `sak install <tool>`. See
`src/docker/setup.sh` for the existing example.

## Local development

Run sak straight from a checkout, without installing it:

```bash
./run.sh list
./run.sh install docker
```

## Infrastructure

`coody.app/install.sh` is served by a Cloudflare Worker (`coody-sak-prd-01`)
that proxies this repo's `install.sh` — see
[`cloudflare/README.md`](cloudflare/README.md) for the deploy runbook.
