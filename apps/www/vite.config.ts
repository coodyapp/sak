import fs from "fs"
import path from "path"
import tailwindcss from "@tailwindcss/vite"
import react from "@vitejs/plugin-react"
import { defineConfig } from "vite"

// Single source of truth for the version shown on the site: apps/cli/bin/sak.
const sakBin = fs.readFileSync(
  path.resolve(__dirname, "../cli/bin/sak"),
  "utf-8",
)
const sakVersionMatch = sakBin.match(/SAK_VERSION="([0-9]+\.[0-9]+\.[0-9]+)"/)
if (!sakVersionMatch) {
  throw new Error("Could not find SAK_VERSION in apps/cli/bin/sak")
}
const SAK_VERSION = sakVersionMatch[1]

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  define: {
    "import.meta.env.VITE_SAK_VERSION": JSON.stringify(SAK_VERSION),
  },
})
