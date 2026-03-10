import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";

export default defineConfig({
  site: "https://www.copywritingseo.pl",
  integrations: [
    sitemap({
      changefreq: "weekly",
      priority: 0.7,
      lastmod: new Date(),
      filter: (page) => !page.includes("/polityka-prywatnosci"),
    }),
  ],
  markdown: {
    shikiConfig: {
      theme: "github-dark",
      wrap: true,
    },
  },
  image: {
    service: { entrypoint: "astro/assets/services/sharp" },
  },
  prefetch: {
    prefetchAll: false,
    defaultStrategy: "hover",
  },
  build: {
    inlineStylesheets: "auto",
  },
});
