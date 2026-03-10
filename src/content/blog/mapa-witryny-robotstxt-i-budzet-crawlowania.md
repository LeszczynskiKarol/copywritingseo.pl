---
title: "Mapa witryny, robots.txt i budżet crawlowania — techniczne minimum, które musisz znać"
description: "Mapa witryny XML (sitemap), plik robots.txt i budżet crawlowania to trzy techniczne elementy SEO, które decydują o tym, czy Google w ogóle odkryje i zaindeksuje Twoje treści. Praktyczny poradnik: co sprawdzić, jak naprawić typowe problemy i kiedy wołać programistę."
pubDate: 2026-04-24
updatedDate: 2026-04-24
heroImage: "/images/blog/sitemap-robots-crawl-budget.jpg"
heroImageAlt: "Mapa witryny, robots.txt, budżet crawlowania — techniczne SEO"
category: "seo-techniczne"
tags:
  [
    "sitemap xml",
    "robots.txt",
    "budżet crawlowania",
    "crawl budget",
    "indeksowanie google",
    "seo techniczne twórca treści",
  ]
readingTime: 14
pillar: false
relatedPosts:
  [
    "indeksowanie-canonical-noindex-pulapki-techniczne",
    "struktura-url-architektura-witryny-seo",
  ]
---

**Mapa witryny XML (sitemap) to plik listujący wszystkie strony, które chcesz, żeby Google zaindeksował; robots.txt to plik mówiący robotom, które katalogi mogą crawlować, a których nie; budżet crawlowania to limit stron, które Googlebot odwiedzi na Twojej witrynie w danym okresie.** Te trzy elementy — sitemap, robots.txt i crawl budget — tworzą infrastrukturę, od której zależy, czy Twój nowy artykuł trafi do Google w 2 dni czy w 2 tygodnie — albo nie trafi wcale.

Żaden z nich nie jest „Twoim problemem" jako twórcy treści w tym sensie, że nie powinieneś ich implementować — od tego jest programista lub CMS. Ale każdy z nich może być Twoim problemem w sensie praktycznym: źle skonfigurowany robots.txt blokuje cały blog, brak sitemapy opóźnia indeksowanie o tygodnie, a marnowanie budżetu crawlowania na martwe strony sprawia, że nowe artykuły są crawlowane rzadziej. Jako twórca treści musisz wiedzieć, co sprawdzić, jak zidentyfikować problem i co powiedzieć programiście, żeby go naprawił.

## Mapa witryny XML (sitemap) — lista stron „do zaindeksowania"

### Czym jest sitemap i gdzie się znajduje

Sitemap to plik XML (zwykle pod adresem `twojastrona.pl/sitemap.xml`) zawierający listę URL-i, które chcesz, żeby Google zaindeksował. Dla każdego URL-a zawiera datę ostatniej modyfikacji — co pomaga Google zdecydować, które strony warto ponownie sprawdzić.

Sitemap nie jest gwarancją indeksowania — to sugestia. Google może zignorować strony z sitemapy (jeśli uzna je za niskiej jakości) lub zaindeksować strony, których w sitemapie nie ma (jeśli znajdzie je przez linki). Ale sitemap znacząco przyspiesza odkrywanie nowych stron — szczególnie na witrynach z setkami podstron, gdzie Googlebot nie jest w stanie regularnie crawlować każdej strony przez same linki wewnętrzne.

### Co twórca treści musi sprawdzić

**Czy sitemap istnieje.** Wpisz `twojastrona.pl/sitemap.xml` w przeglądarkę. Jeśli widzisz plik XML z listą URL-i — jest. Jeśli widzisz błąd 404 — nie ma sitemapy. Skontaktuj się z programistą. Na WordPress: Yoast SEO lub Rank Math generują sitemapę automatycznie. Na Astro: integracja `@astrojs/sitemap`. Na Next.js: `next-sitemap`.

**Czy sitemap jest zgłoszony w Google Search Console.** GSC → Mapy witryn → sprawdź, czy URL sitemapy jest zgłoszony i status to „Sukces". Jeśli nie jest zgłoszony — zgłoś go (wklej URL i kliknij „Prześlij").

**Czy nowe artykuły pojawiają się w sitemapie.** Po opublikowaniu nowego artykułu odczekaj minutę i odśwież sitemap w przeglądarce. Czy nowy URL jest na liście? Jeśli nie — sitemap nie regeneruje się automatycznie przy publikacji. Problem do zgłoszenia programiście.

**Czy w sitemapie nie ma stron z noindex.** Sprzeczne sygnały: sitemap mówi „zaindeksuj", noindex mówi „nie indeksuj". Google radzi sobie z tą sprzecznością, ale to niepotrzebny szum. Screaming Frog umożliwia porównanie sitemapy z dyrektywami noindex — wyłapuje te konflikty automatycznie.

**Czy sitemap nie jest za duży.** Limit Google: 50 000 URL-i lub 50 MB na plik. Jeśli Twoja witryna ma więcej — potrzebujesz indeksu sitemap (sitemap of sitemaps). Ale to dotyczy witryn z 50 000+ stron — większość blogów się nie kwalifikuje.

### Najczęstsze problemy z sitemapą

| Problem                           | Jak wykryć                                        | Jak naprawić                                   |
| --------------------------------- | ------------------------------------------------- | ---------------------------------------------- |
| Brak sitemapy                     | `/sitemap.xml` zwraca 404                         | Wdrożenie przez CMS lub generator statyczny    |
| Sitemap nie zgłoszony w GSC       | GSC → Mapy witryn → puste                         | Zgłoś URL sitemapy w GSC                       |
| Nowe artykuły nie pojawiają się   | Odśwież sitemap — brak nowego URL                 | Napraw automatyczną regenerację                |
| Strony z noindex w sitemapie      | Screaming Frog: porównanie sitemap vs meta robots | Usuń strony noindex z sitemapy                 |
| Stare/usunięte strony w sitemapie | Sitemap zawiera URL-e zwracające 404              | Wyczyść sitemapę z martwych linków             |
| Sitemap bez dat modyfikacji       | `<lastmod>` brakuje                               | Dodaj `<lastmod>` z datą aktualizacji artykułu |

## Robots.txt — kto może crawlować co

### Czym jest robots.txt

Plik `robots.txt` (pod adresem `twojastrona.pl/robots.txt`) to zestaw instrukcji dla robotów wyszukiwarek: które katalogi mogą crawlować, a których nie. Przykład:

```
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Sitemap: https://twojastrona.pl/sitemap.xml
```

To mówi: „Wszyscy roboty mogą crawlować wszystko, z wyjątkiem katalogów `/admin/` i `/api/`. Sitemap jest pod tym adresem."

### Co twórca treści musi sprawdzić

**Czy robots.txt nie blokuje Twoich treści.** Wpisz `twojastrona.pl/robots.txt` w przeglądarkę i przeczytaj zawartość. Jeśli widzisz `Disallow: /blog/` — Twój cały blog jest zablokowany dla Googlebota. Jeśli widzisz `Disallow: /` — cała strona jest zablokowana. Oba scenariusze to katastrofa wymagająca natychmiastowej interwencji.

**Czy robots.txt zawiera odniesienie do sitemapy.** Linia `Sitemap: https://twojastrona.pl/sitemap.xml` na końcu pliku ułatwia Google znalezienie Twojej sitemapy. To nie jest obowiązkowe (sitemapę zgłaszasz też w GSC), ale jest dobrą praktyką.

**Czy robots.txt nie blokuje zasobów (CSS, JS, obrazy).** Googlebot renderuje strony — potrzebuje dostępu do CSS i JavaScript, żeby zobaczyć stronę tak, jak widzi ją użytkownik. Jeśli robots.txt blokuje `/css/` lub `/js/` — Google może niepoprawnie renderować Twoje strony, co wpływa na indeksowanie i pozycje.

### Robots.txt vs noindex — kluczowa różnica

|                                 | robots.txt `Disallow`                                                                                       | `<meta name="robots" content="noindex">`                                           |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **Co robi**                     | Blokuje crawlowanie — Googlebot nie odwiedza strony                                                         | Pozwala crawlować, ale zabrania indeksowania                                       |
| **Czy strona jest w indeksie?** | Może być (!) — jeśli inne strony linkują do niej, Google może ją zaindeksować z samego URL, bez crawlowania | Nie — Google usuwa stronę z indeksu                                                |
| **Kiedy stosować**              | Zasoby techniczne (admin, API, pliki prywatne)                                                              | Strony, które nie powinny być w wynikach (logowanie, podziękowanie, archiwa tagów) |

Pułapka, którą wielu popełnia: chcesz usunąć stronę z Google, więc dodajesz `Disallow` w robots.txt. Ale to blokuje crawlowanie — Googlebot nie może odwiedzić strony, więc nie zobaczy dyrektywy noindex. Efekt: strona nadal może być w indeksie (z samego URL). Prawidłowe rozwiązanie do usunięcia z indeksu: noindex, nie robots.txt.

### Kiedy wołać programistę

Natychmiast, jeśli: robots.txt blokuje `/blog/` lub `/` (wszystko), robots.txt blokuje CSS/JS/obrazy, robots.txt nie istnieje w ogóle (choć to rzadko problem — brak pliku = „crawluj wszystko"), robots.txt zawiera błędy składniowe (narzędzie „Tester robots.txt" w starszej wersji GSC lub zewnętrzne narzędzia).

## Budżet crawlowania — kiedy jest problemem i co z tym zrobić

### Kiedy budżet crawlowania NIE jest Twoim problemem

Jeśli Twoja witryna ma mniej niż 1 000 stron i jest na przyzwoitym hostingu — budżet crawlowania nie jest ograniczeniem. Google crawluje małe witryny wystarczająco często, żeby odkrywać nowe strony w ciągu dni. Nie optymalizuj czegoś, co nie jest wąskim gardłem.

### Kiedy budżet crawlowania JEST problemem

Witryny z 5 000+ stron, szczególnie jeśli: duża część stron jest niskiej jakości (duplikaty, cienkie treści, martwe strony), strona jest wolna (Googlebot ogranicza crawlowanie na wolnych serwerach), wiele stron generuje błędy 5xx (serwer nie odpowiada).

Symptomy: nowe artykuły indeksowane z opóźnieniem (2+ tygodnie zamiast 2–3 dni), raport w GSC „Crawl Stats" (Statystyki crawlowania) pokazuje spadek crawlowanych stron dziennie, wiele ważnych stron ma status „Odkryto — obecnie nie zaindeksowano".

### Co twórca treści może zrobić

**Usuwaj lub deindeksuj strony niskiej jakości.** Każda martwa strona, którą Googlebot crawluje, to strona zabrana z budżetu. Audyt treści (artykuł 2.9) bezpośrednio poprawia efektywność crawlowania.

**Linkuj nowe artykuły z istniejących stron.** Googlebot podąża za linkami. Nowy artykuł zlinkowany z 5 istniejących stron jest crawlowany szybciej niż artykuł bez linków. To jest SEO-wy powód, dla którego linkowanie wewnętrzne po publikacji jest tak ważne.

**Upewnij się, że sitemap jest aktualny.** Sitemap z datami `<lastmod>` pomaga Googlebotowi priorytetyzować: „Ta strona była modyfikowana wczoraj — sprawdzę ją najpierw."

**Nie generuj zbędnych URL-i.** Strony tagów, archiwa dat, strony wyników wyszukiwania wewnętrznego, strony filtrów — jeśli nie mają wartości SEO, ustaw noindex lub zablokuj w robots.txt. Każda taka strona konsumuje budżet crawlowania.

## Praktyczna checklist — 5 minut raz w miesiącu

Poświęć 5 minut raz w miesiącu na weryfikację:

**1. Sitemap** (`/sitemap.xml`): Otwórz w przeglądarce — czy się ładuje? Czy zawiera Twoje najnowsze artykuły? Czy nie zawiera stron 404 lub stron z noindex?

**2. Robots.txt** (`/robots.txt`): Otwórz w przeglądarce — czy nie blokuje `/blog/` ani `/`? Czy zawiera linię `Sitemap:`?

**3. GSC — Mapy witryn**: Czy sitemap jest zgłoszony? Czy status to „Sukces"? Ile URL-i Google wykrył vs ile zaindeksował?

**4. GSC — Strony**: Ile stron „Nie zaindeksowano"? Czy przyczyny są zrozumiałe (noindex = celowo) czy podejrzane (odkryto, ale nie zaindeksowano = problem jakości)?

**5. GSC — Inspekcja URL**: Dla 2–3 najnowszych artykułów — czy są zaindeksowane? Jeśli artykuł sprzed 2 tygodni nie jest zaindeksowany — zbadaj dlaczego.

Jeśli którykolwiek z tych punktów zwraca alarm — eskaluj do programisty z konkretnym opisem problemu. Nie mów „coś jest nie tak z SEO" — powiedz „sitemap pod `/sitemap.xml` zwraca 404" lub „robots.txt blokuje `/blog/`". Konkretny problem = szybka naprawa.

## Narzędzia do diagnostyki

| Narzędzie                                      | Co sprawdza                                                                           | Koszt              |
| ---------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------ |
| **Google Search Console**                      | Sitemapa, indeksowanie, crawl stats, robots.txt                                       | Darmowe            |
| **Screaming Frog**                             | Crawl witryny: sitemap vs rzeczywistość, robots.txt, statusy HTTP, canonical, noindex | Darmowe do 500 URL |
| **Google Rich Results Test**                   | Renderowanie strony — czy Google widzi to co Ty                                       | Darmowe            |
| **Robots.txt Tester** (różne narzędzia online) | Walidacja składni robots.txt                                                          | Darmowe            |
| **Ahrefs Site Audit**                          | Kompleksowy audyt techniczny z priorytetyzacją problemów                              | Od ~99 USD/mies.   |

## FAQ

### Czy każda strona internetowa potrzebuje sitemapy?

Technicznie nie — Google może odkryć strony przez linki wewnętrzne i zewnętrzne. Ale praktycznie — tak, każda. Sitemap przyspiesza odkrywanie nowych stron, pomaga Google priorytetyzować crawlowanie i jest standardową praktyką, której brak może tylko zaszkodzić, nigdy pomóc.

### Czy mogę edytować robots.txt sam, bez programisty?

Jeśli masz dostęp do pliku (na WordPressie: Yoast SEO → Narzędzia → Edytor pliku robots.txt; na statycznych stronach: plik w katalogu głównym) — technicznie tak. Ale jeden błąd w robots.txt może zablokować całą witrynę. Jeśli nie jesteś pewien składni — poproś programistę. To 5-minutowa zmiana dla niego, a potencjalna katastrofa w Twoich rękach.

### Jak sprawdzić, czy Googlebot crawluje moją stronę regularnie?

Google Search Console → Ustawienia → Statystyki crawlowania. Zobaczysz wykres: ile stron Googlebot crawlował dziennie, średni czas odpowiedzi serwera i statusy HTTP. Jeśli wykres pokazuje spadek crawlowania — to sygnał problemu (wolny serwer, błędy 5xx, blokada w robots.txt).

### Czy muszę zgłaszać sitemapę przy każdej aktualizacji?

Nie — wystarczy zgłosić raz. Google regularnie sprawdza sitemapę pod zgłoszonym URL-em. Jeśli sitemap regeneruje się automatycznie przy publikacji (a powinien) — Google zobaczy nowe URL-e przy kolejnym sprawdzeniu. Ręczne ponowne zgłoszenie ma sens tylko po dużej migracji lub przebudowie witryny.

### Ile stron dziennie Googlebot crawluje na typowej witrynie?

Zależy od autorytetu domeny i rozmiaru witryny. Nowa strona z DR < 10: 5–20 stron dziennie. Blog z DR 20–40 i 100 stronami: 50–200 stron dziennie. Duży portal z DR 60+ i tysiącami stron: 1 000–10 000+ stron dziennie. Liczby orientacyjne — sprawdź realne dane w GSC → Statystyki crawlowania.
