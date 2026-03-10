/**
 * Estimate reading time for a given text
 */
export function getReadingTime(text: string): number {
  const wordsPerMinute = 200;
  const words = text.trim().split(/\s+/).length;
  return Math.max(1, Math.ceil(words / wordsPerMinute));
}

/**
 * Format a date in Polish locale
 */
export function formatDate(date: Date): string {
  return date.toLocaleDateString("pl-PL", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

/**
 * Format date as ISO string for schema.org
 */
export function formatDateISO(date: Date): string {
  return date.toISOString();
}

/**
 * Category metadata mapping
 */
export const CATEGORIES: Record<
  string,
  { name: string; description: string; color: string; icon: string }
> = {
  "podstawy-seo": {
    name: "Podstawy SEO Copywritingu",
    description:
      "Fundamenty tworzenia treści zoptymalizowanych pod wyszukiwarki.",
    color: "#2563eb",
    icon: "📘",
  },
  "strategia-tresci": {
    name: "Strategia i Planowanie Treści",
    description:
      "Planowanie, klastry tematyczne, brief contentowy i kalendarz redakcyjny.",
    color: "#7c3aed",
    icon: "🗺️",
  },
  "pisanie-optymalizacja": {
    name: "Pisanie i Optymalizacja",
    description:
      "Techniki pisania, on-page SEO, struktura tekstu i formatowanie.",
    color: "#059669",
    icon: "✍️",
  },
  "ai-copywriting": {
    name: "AI w SEO Copywritingu",
    description:
      "Sztuczna inteligencja, prompt engineering i AI-powered workflows.",
    color: "#d97706",
    icon: "🤖",
  },
  "seo-techniczne": {
    name: "SEO Techniczne",
    description:
      "Core Web Vitals, schema markup, indeksowanie i struktura URL.",
    color: "#64748b",
    icon: "🔧",
  },
};

/**
 * Get category info by slug
 */
export function getCategoryInfo(slug: string) {
  return CATEGORIES[slug] || CATEGORIES["podstawy-seo"];
}

/**
 * Truncate text to a maximum number of characters
 */
export function truncate(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength).replace(/\s+\S*$/, "") + "…";
}

/**
 * Generate slug from text
 */
export function slugify(text: string): string {
  return text
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[łŁ]/g, "l")
    .replace(/[^\w\s-]/g, "")
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-")
    .trim();
}

/**
 * Site-wide constants
 */
export const SITE = {
  title: "SEO copywriting - pisanie tekstów do Google i pozycjonowania",
  description:
    "Praktyczne poradniki SEO copywritingu, strategii treści, AI w content marketingu i Generative Engine Optimization. Twórz treści, które rankują.",
  author: "Karol Leszczyński",
  url: "https://www.copywritingseo.pl",
  ogImage: "/images/og-default.jpg",
  postsPerPage: 12,
} as const;
