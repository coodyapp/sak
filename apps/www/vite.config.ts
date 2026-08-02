import fs from "fs"
import path from "path"
import tailwindcss from "@tailwindcss/vite"
import react from "@vitejs/plugin-react"
import { defineConfig, type Plugin } from "vite"

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

const SITE_ORIGIN = "https://sak.coody.app"

// The site is a single canonical URL, so the sitemap is generated rather than
// checked in: that keeps <lastmod> honest on every publish instead of leaving a
// stale date in the repo. Referenced from public/robots.txt.
function sitemap(): Plugin {
  return {
    name: "sak-sitemap",
    apply: "build",
    generateBundle() {
      const lastmod = new Date().toISOString().slice(0, 10)
      this.emitFile({
        type: "asset",
        fileName: "sitemap.xml",
        source: `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>${SITE_ORIGIN}/</loc>
    <lastmod>${lastmod}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
`,
      })
    },
  }
}

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss(), sitemap()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  define: {
    "import.meta.env.VITE_SAK_VERSION": JSON.stringify(SAK_VERSION),
  },
})
