import { type CSSProperties } from "react"

import { SiteFooter } from "@/components/site-footer"
import { Terminal } from "@/components/terminal"

const INSTALL_CMD = "curl -fsSL https://coody.app/install.sh | bash"
const VERSION = `v${import.meta.env.VITE_SAK_VERSION}`
const VERSION_STYLE = {
  "--version-width": `${VERSION.length}ch`,
} as CSSProperties

const LOGO = `  █████████    █████████   █████   ████
 ███░░░░░███  ███░░░░░███ ░░███   ███░
░███    ░░░  ░███    ░███  ░███  ███
░░█████████  ░███████████  ░███████
 ░░░░░░░░███ ░███░░░░░███  ░███░░███
 ███    ░███ ░███    ░███  ░███ ░░███
░░█████████  █████   █████ █████ ░░████
 ░░░░░░░░░  ░░░░░   ░░░░░ ░░░░░   ░░░░ `

const USAGE_COMMANDS = [
  "sak list              # see available tools",
  "sak install <tool>    # install one, e.g. `sak install docker`",
  "sak update            # pull the latest sak + tool scripts",
  "sak version",
]

export function App() {
  return (
    <>
      <div aria-hidden className="glitch-background" />
      <main className="relative z-10 mx-auto flex min-h-svh max-w-3xl flex-col gap-16 px-6 py-20 sm:py-28">
        <div className="flex flex-col gap-6">
          <pre className="animate-logo overflow-x-auto font-mono text-[0.6rem] leading-tight text-primary sm:text-xs">
            {LOGO}
          </pre>

          <div className="flex flex-col gap-4">
            <p className="font-mono text-xs tracking-wide text-muted-foreground uppercase">
              <span className="version-typewriter" style={VERSION_STYLE}>
                {VERSION}
              </span>
            </p>
            <h1 className="text-4xl font-semibold tracking-tight sm:text-5xl">
              Install the tools you actually use.
            </h1>
            <p className="max-w-md text-lg text-muted-foreground">
              A Swiss Army Knife that sets up your dev tools with a single
              command.
            </p>
          </div>
        </div>

        <Terminal id="install" commands={[INSTALL_CMD]} typewriter>
          Installs <code>sak</code> CLI to <code>~/.sak</code> and adds it to
          your <code>PATH</code>.
        </Terminal>

        <Terminal commands={USAGE_COMMANDS} typewriter>
          Common commands after <code>sak</code> is installed.
        </Terminal>

        <section className="border-l-2 border-primary/40 pl-4 font-mono text-sm text-muted-foreground">
          <p>
            Currently supported:{" "}
            <strong className="text-foreground">
              Debian-based Linux and macOS
            </strong>{" "}
            for sak itself and the ops commands. Installing tools (
            <code>sak install &lt;tool&gt;</code>) requires Debian-based Linux
            (Ubuntu, Debian, etc) for now.
          </p>
        </section>

        <SiteFooter />
      </main>
    </>
  )
}

export default App
