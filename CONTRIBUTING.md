# Contributing to SAK

Thanks for considering a contribution.

## Dev setup

The CLI (`apps/cli/`) has no build step. Clone the repo and run it straight
from the checkout:

```bash
./apps/cli/run.sh list
./apps/cli/run.sh install docker
```

`run.sh` just execs `bin/sak` with `SAK_HOME` pointed at the checkout, so
changes to `lib/` or `src/` are picked up immediately.

`apps/worker/` and `apps/www/` are pnpm workspaces:

```bash
pnpm install        # from the repo root
cd apps/www && pnpm run dev
```

## Adding a tool

Create `apps/cli/src/<tool>/setup.sh` and `apps/cli/src/<tool>/meta.sh`:

- `setup.sh` — a self-contained, idempotent install script. It should be safe
  to run more than once and should not assume anything beyond a Debian-based
  Linux host (see `apps/cli/lib/os.sh`).
- `meta.sh` — declares `TOOL_NAME`, `TOOL_BIN`, and `TOOL_DESCRIPTION`, used by
  `sak list` to show the tool's display name, installed version, and a short
  description. See `apps/cli/src/docker/` for a working example.

The tool shows up in `sak list` and becomes installable via
`sak install <tool>` automatically — no registry to update.

## Shell style

- `set -euo pipefail` at the top of every script.
- Keep scripts [shellcheck](https://www.shellcheck.net/)-clean:
  `shellcheck apps/cli/bin/sak apps/cli/lib/*.sh apps/cli/src/*/*.sh install.sh apps/cli/run.sh`
- Prefer plain POSIX-ish bash over bashisms that aren't load-bearing.

## Tests

CLI behavior is covered by [bats](https://github.com/bats-core/bats-core) in
`test/cli/`:

```bash
bats test/cli
```

Add or update a `.bats` case alongside any change to `bin/sak`'s behavior.

## Pull requests

- Keep PRs focused — one change per PR.
- Make sure `shellcheck` and `bats test/cli` pass locally before opening.
- Describe what changed and why in the PR description; link any related issue.
- By participating, you agree to follow the
  [Code of Conduct](CODE_OF_CONDUCT.md).
