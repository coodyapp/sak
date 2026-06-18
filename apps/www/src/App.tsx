import { useState } from "react"
import { Check, Copy } from "lucide-react"
import { toast } from "sonner"

import { Button } from "@/components/ui/button"

const INSTALL_CMD = "curl -fsSL https://coody.app/install.sh | bash"

const LOGO = `  █████████    █████████   █████   ████
 ███░░░░░███  ███░░░░░███ ░░███   ███░
░███    ░░░  ░███    ░███  ░███  ███
░░█████████  ░███████████  ░███████
 ░░░░░░░░███ ░███░░░░░███  ░███░░███
 ███    ░███ ░███    ░███  ░███ ░░███
░░█████████  █████   █████ █████ ░░████
 ░░░░░░░░░  ░░░░░   ░░░░░ ░░░░░   ░░░░ `

const USAGE = `sak list              # see available tools
sak install <tool>    # install one, e.g. \`sak install docker\`
sak update            # pull the latest sak + tool scripts
sak version`

export function App() {
  const [copied, setCopied] = useState(false)

  const copyInstallCmd = async () => {
    await navigator.clipboard.writeText(INSTALL_CMD)
    setCopied(true)
    toast("Copied to clipboard")
    setTimeout(() => setCopied(false), 1500)
  }

  return (
    <main className="mx-auto flex min-h-svh max-w-3xl flex-col gap-16 px-6 py-20 sm:py-28">
      <div className="flex flex-col gap-6">
        <pre className="animate-logo overflow-x-auto font-mono text-[0.6rem] leading-tight text-primary sm:text-xs">
          {LOGO}
        </pre>

        <div className="flex flex-col gap-4">
          <p className="font-mono text-xs tracking-wide text-muted-foreground uppercase">
            Powered by coody.app
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

      <section className="flex flex-col gap-3">
        <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:gap-3">
          <pre className="flex-1 overflow-x-auto rounded-md border border-border bg-card p-4 font-mono">
            <code>{INSTALL_CMD}</code>
          </pre>
          <Button type="button" size="sm" onClick={copyInstallCmd}>
            {copied ? (
              <Check className="size-3.5" />
            ) : (
              <Copy className="size-3.5" />
            )}
            {copied ? "copied" : "copy"}
          </Button>
        </div>
        <p className="font-mono text-sm text-muted-foreground">
          Installs the <code>sak</code> CLI to <code>~/.sak</code> and adds it
          to your <code>PATH</code>.
        </p>
      </section>

      <section className="flex flex-col gap-3">
        <h2 className="font-mono text-xs tracking-wide text-muted-foreground uppercase">
          Usage
        </h2>
        <pre className="overflow-x-auto rounded-md border border-border bg-card p-4 font-mono">
          <code>{USAGE}</code>
        </pre>
      </section>

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

      <footer className="flex items-center gap-2 border-t border-border pt-6 font-mono text-sm text-muted-foreground">
        <a
          href="https://github.com/coodyapp/sak"
          className="text-primary hover:underline"
        >
          github.com/coodyapp/sak
        </a>
        <span>·</span>
        <span>
          Powered by{" "}
          <a
            href="https://coody.app"
            target="_blank"
            rel="noopener noreferrer"
            className="relative text-foreground transition-colors duration-300 after:absolute after:bottom-0 after:left-0 after:h-px after:w-0 after:bg-primary after:transition-all after:duration-300 hover:text-primary hover:after:w-full"
          >
            Coody
          </a>
        </span>
      </footer>
    </main>
  )
}

export default App
