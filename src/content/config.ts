import { defineCollection, z } from "astro:content";

const blog = defineCollection({
  type: "content",
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    heroImage: z.string().optional(),
    heroImageAlt: z.string().optional(),
    category: z.enum([
      "podstawy-seo",
      "strategia-tresci",
      "pisanie-optymalizacja",
      "ai-copywriting",
      "geo-optymalizacja",
      "content-operations",
      "seo-techniczne",
    ]).default("podstawy-seo"),
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
    readingTime: z.number().optional(),
    author: z.string().default("Karol Leszczyński"),
    pillar: z.boolean().default(false),
    relatedPosts: z.array(z.string()).default([]),
  }),
});

export const collections = { blog };
