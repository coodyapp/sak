import { useState } from "react"
import { Check, Copy } from "lucide-react"

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
    setTimeout(() => setCopied(false), 1500)
  }

  return (
    <main className="mx-auto flex min-h-svh max-w-2xl flex-col gap-10 px-6 py-16 font-mono">
      <div>
        <pre className="overflow-x-auto text-[0.6rem] leading-tight text-primary sm:text-xs">
          {LOGO}
        </pre>
        <p className="mt-3 text-muted-foreground">Powered by coody.app</p>
      </div>

      <p className="text-lg">
        A Swiss Army Knife that installs the tools you actually use, with a
        single command.
      </p>

      <section className="flex flex-col gap-2">
        <div className="relative">
          <pre className="overflow-x-auto rounded-md border border-border bg-card p-4">
            <code>{INSTALL_CMD}</code>
          </pre>
          <Button
            type="button"
            size="sm"
            variant="outline"
            className="absolute top-2 right-2"
            onClick={copyInstallCmd}
          >
            {copied ? (
              <Check className="size-3.5" />
            ) : (
              <Copy className="size-3.5" />
            )}
            {copied ? "copied" : "copy"}
          </Button>
        </div>
        <p className="text-sm text-muted-foreground">
          Installs the <code>sak</code> CLI to <code>~/.sak</code> and adds it
          to your <code>PATH</code>.
        </p>
      </section>

      <section className="flex flex-col gap-3">
        <h2 className="text-xs tracking-wide text-muted-foreground uppercase">
          Usage
        </h2>
        <pre className="overflow-x-auto rounded-md border border-border bg-card p-4">
          <code>{USAGE}</code>
        </pre>
      </section>

      <section className="border-l-2 border-border pl-4 text-sm text-muted-foreground">
        <p>
          Currently supported:{" "}
          <strong className="text-foreground">Debian-based Linux only</strong>{" "}
          (Ubuntu, Debian, etc). Other operating systems are coming soon.
        </p>
      </section>

      <footer className="flex items-center gap-2 border-t border-border pt-6 text-sm text-muted-foreground">
        <a
          href="https://github.com/coodyapp/sak"
          className="text-primary hover:underline"
        >
          github.com/coodyapp/sak
        </a>
        <span>·</span>
        <span>Powered by Coody</span>
      </footer>
    </main>
  )
}

export default App
