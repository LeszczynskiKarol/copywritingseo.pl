---
title: "Prompt engineering dla SEO — jak pisać prompty, które dają treści nadające się do publikacji"
description: "Prompt engineering dla SEO to umiejętność konstruowania instrukcji dla modeli AI (Claude, ChatGPT), które generują treści zoptymalizowane pod wyszukiwarki, pozbawione halucynacji i napisane w tonie dopasowanym do marki. Poznaj sprawdzone wzorce promptów z konkretnymi przykładami."
pubDate: 2026-04-04
updatedDate: 2026-04-04
heroImage: "/images/blog/prompt-engineering-seo.jpg"
heroImageAlt: "Prompt engineering dla SEO — jak rozmawiać z AI o treściach"
category: "ai-copywriting"
tags:
  [
    "prompt engineering seo",
    "prompty do treści",
    "ai copywriting prompty",
    "jak promptować ai",
    "chatgpt seo prompty",
    "claude prompty",
  ]
readingTime: 15
pillar: false
relatedPosts:
  [
    "ai-seo-copywriting-co-naprawde-dziala",
    "checklist-seo-copywritera-lista-kontrolna",
  ]
---

**Prompt engineering dla SEO to umiejętność konstruowania instrukcji (promptów) dla modeli AI — Claude, ChatGPT, Gemini — w sposób, który generuje treści zoptymalizowane pod wyszukiwarki: ze strukturą nagłówków, odpowiedzią w pierwszych 100 słowach, naturalnym osadzeniem fraz kluczowych i tonem dopasowanym do grupy docelowej.** Różnica między dobrym a złym promptem to różnica między szkicem wymagającym 20 minut redakcji a szkicem wymagającym przepisania od zera.

Zanim przejdziemy do promptów: żaden prompt nie zrekompensuje braku strategii. Jeśli nie wiesz, na jaką frazę celujesz, jaka jest intencja użytkownika i jaki format wymuszają wyniki Google — najlepszy prompt świata wygeneruje pięknie napisany artykuł, który nigdy nie wejdzie do top 10. Prompt engineering to ostatni krok w łańcuchu: strategia → badanie fraz → analiza SERP → brief → prompt → szkic → redakcja.

## Dlaczego generyczne prompty generują generyczne treści

Prompt: „Napisz artykuł o SEO copywritingu." Efekt: 1 500 słów ogólników, które brzmią jak streszczenie Wikipedii. Brak struktury pod SEO, brak frazy w pierwszych 100 słowach, brak danych, brak perspektywy autora.

Dlaczego? Bo model AI nie wie: kto jest czytelnikiem (początkujący? ekspert? właściciel sklepu?), jaka jest fraza kluczowa i intencja, jaki format sprawdza się w wynikach Google na tę frazę, jaki ton i styl masz na blogu, jakie dane i przykłady chcesz uwzględnić, czego NIE chcesz (ogólników, korporacyjnego tonu, wymyślonych statystyk).

Im mniej kontekstu dasz modelowi, tym bardziej „domyślny" będzie output. A domyślny output AI to gładki, poprawny, bezwartościowy tekst, który mógłby być na każdym blogu w internecie.

## Anatomia skutecznego promptu SEO — framework RSKF

Po testowaniu dziesiątek struktur promptów, stosuję framework, który nazywam RSKF: Rola, Specyfikacja, Kontekst, Format.

### R — Rola

Powiedz modelowi, kim jest w kontekście tego zadania. Nie „jesteś copywriterem", bo to za ogólne. Konkretnie:

„Jesteś doświadczonym polskim SEO copywriterem, który od 5 lat pisze artykuły eksperckie dla blogów firm z branży e-commerce. Piszesz w tonie profesjonalnym, ale przystępnym — jak na spotkaniu z kompetentnym klientem. Unikasz korporacyjnego żargonu, anglicyzmów wplecionych w polskie zdania i pustych frazesów."

### S — Specyfikacja zadania

Co dokładnie ma powstać, z jakimi parametrami:

„Napisz artykuł blogowy na temat [TEMAT]. Fraza kluczowa: [FRAZA]. Intencja wyszukiwania: informacyjna. Długość: 2 000–2 500 słów. Struktura: H1 + 6–8 nagłówków H2 + H3 gdzie potrzebne + sekcja FAQ (4 pytania)."

### K — Kontekst

Tu wkładasz wszystko, co model musi wiedzieć, żeby pisać mądrze:

„Artykuły w top 5 na tę frazę mają strukturę: [wklejasz nagłówki z 3 artykułów konkurencji]. Mój blog jest skierowany do [GRUPA DOCELOWA]. Artykuł jest częścią klastra tematycznego '[KLASTER]' i powinien linkować do: [LISTA URL-i z kotwicami]. Dane, które chcę uwzględnić: [WKLEJASZ KONKRETNE STATYSTYKI ZE ŹRÓDŁAMI]."

### F — Format i ograniczenia

Reguły, których model musi przestrzegać:

„Pierwszy akapit: pogrubiona definicja tematu w 40–60 słowach z frazą kluczową + kontekst + zarys artykułu. Każda sekcja H2: zrozumiała samodzielnie, bez odwołań do innych sekcji. Akapity: 2–4 zdania. Minimum 1 tabela w artykule. Nie wymyślaj statystyk — używaj wyłącznie danych podanych w kontekście. Nie pisz 'w dzisiejszym dynamicznym świecie', 'warto podkreślić', 'nie bez znaczenia'. Pisz po polsku — bez anglicyzmów wplecionych w polskie zdania (zamiast 'CTR' używaj 'współczynnik klikalności', zamiast 'backlinki' — 'odnośniki zwrotne')."

## 7 promptów, które naprawdę działają — gotowe szablony

### Prompt 1: Generowanie struktury nagłówków

```
Przeanalizuj top 5 artykułów rankujących na frazę "[FRAZA]".
Oto ich nagłówki H2:

Artykuł 1: [wklej nagłówki]
Artykuł 2: [wklej nagłówki]
Artykuł 3: [wklej nagłówki]

Na podstawie tej analizy:
1. Zidentyfikuj podtematy, które pokrywają wszyscy (obowiązkowe).
2. Zidentyfikuj podtematy, które pokrywa tylko 1 artykuł (potencjalne wyróżniki).
3. Zidentyfikuj luki — podtematy, których nie pokrywa nikt (okazje).
4. Zaproponuj strukturę H2/H3 dla mojego artykułu, który ma być lepszy od wszystkich trzech.
```

Dlaczego działa: zamiast prosić AI o „wymyślenie" struktury, dajesz mu dane z realnych wyników Google. Model pracuje na faktach, nie na wyobraźni.

### Prompt 2: Akapit otwierający (definicja + hook)

```
Napisz akapit otwierający artykuł SEO.

Temat: [TEMAT]
Fraza kluczowa: [FRAZA]
Intencja: [informacyjna/komercyjna/transakcyjna]

Wymagania:
- Pierwsze zdanie: pogrubiona definicja tematu (20–30 słów) z frazą kluczową
- Drugie zdanie: dlaczego to ważne / jaki problem rozwiązuje (20–30 słów)
- Trzecie zdanie: co czytelnik znajdzie w artykule (15–20 słów)
- Łącznie: 60–80 słów
- Fragment musi być zrozumiały samodzielnie (cytowalny przez AI)
- Język: polski, bez anglicyzmów, bez "w dzisiejszym świecie", bez "warto podkreślić"

Wygeneruj 3 warianty, żebym mógł wybrać najlepszy.
```

### Prompt 3: Rozwinięcie sekcji H2 z danymi

```
Napisz sekcję artykułu SEO pod nagłówkiem H2: "[NAGŁÓWEK]"

Kontekst artykułu: [1–2 zdania]
Grupa docelowa: [KTO]

Wymagania:
- Długość: 200–350 słów
- Pierwsze zdanie: kluczowa myśl sekcji (czytelnik skanujący przeczyta tylko to)
- Dane do uwzględnienia: [WKLEJ KONKRETNE FAKTY ZE ŹRÓDŁAMI]
- Zakończ jednym zdaniem łączącym z kolejną sekcją
- Sekcja musi być zrozumiała BEZ czytania reszty artykułu
- Jeśli potrzebna tabela — dodaj
- NIE wymyślaj danych, których nie podałem
```

### Prompt 4: Sekcja FAQ

```
Wygeneruj sekcję FAQ do artykułu o [TEMAT].

Oto pytania z sekcji "Ludzie też pytają" w Google na frazę "[FRAZA]":
1. [pytanie]
2. [pytanie]
3. [pytanie]
4. [pytanie]

Dla każdego pytania napisz odpowiedź:
- 50–80 słów
- Zacznij od bezpośredniej odpowiedzi (tak/nie/to zależy + wyjaśnienie)
- Konkretna, bez ogólników
- Zrozumiała samodzielnie (AI musi móc zacytować bez kontekstu)
```

### Prompt 5: Meta title i meta description

```
Wygeneruj 5 wariantów meta title i 3 warianty meta description
dla artykułu o [TEMAT].

Fraza kluczowa: [FRAZA]
Intencja: [TYP]

Wymagania dla title:
- 40–60 znaków
- Fraza w pierwszych 30 znakach
- Element zachęcający do kliknięcia (rok/format/liczba)

Wymagania dla description:
- 135–155 znaków
- Fraza w pierwszych 60 znakach
- Konkretna korzyść (nie "dowiedz się więcej")
- Element wyróżniający (dane/format/perspektywa praktyka)
```

### Prompt 6: Przeformułowanie pod naturalność

```
Poniższy akapit brzmi zbyt "AI-owo" — przepisz go tak, żeby brzmiał
jak napisany przez doświadczonego polskiego specjalistę SEO,
który pisze bloga z perspektywy praktyka:

[WKLEJ AKAPIT]

Zasady:
- Usuń "warto podkreślić", "nie bez znaczenia", "w dzisiejszym świecie"
- Zamień strony bierne na czynne
- Dodaj konkretny przykład lub scenariusz ilustrujący myśl
- Zachowaj ten sam sens, ale zmień strukturę zdań
- Pisz po polsku bez anglicyzmów
```

### Prompt 7: Weryfikacja tekstu pod kątem problemów AI

```
Przeczytaj poniższy tekst i zidentyfikuj:
1. Fragmenty, które brzmią generycznie ("AI-owo") — powtarzalne frazy,
   puste stwierdzenia, brak konkretu
2. Statystyki lub twierdzenia, które mogą być halucynacjami
   (nie mają podanego źródła lub źródło brzmi podejrzanie)
3. Fragmenty, które powtarzają tę samą myśl innymi słowami
4. Miejsca, gdzie brakuje przykładu lub konkretu

Dla każdego znalezionego problemu zaproponuj konkretną poprawkę.

[WKLEJ TEKST]
```

## Różnice między modelami — jak promptować Claude vs ChatGPT

Claude i ChatGPT reagują na prompty inaczej. Po miesiącach testowania:

**Claude** lepiej odpowiada na prompty deklaratywne i dobrze sformatowane (nagłówki, listy, jasna struktura). Świetnie trzyma się ograniczeń („nie pisz X") i generuje bardziej naturalny polski. Najlepszy do długich tekstów (okno 200k+ tokenów pozwala wkleić 5 artykułów konkurencji jako kontekst). Gorzej radzi sobie z zadaniami wymagającymi bieżących danych z internetu (chyba że z funkcją web search).

**ChatGPT** lepiej odpowiada na krótkie, konkretne instrukcje w stylu markdown. Szybszy w generowaniu wariantów (10 tytułów w sekundę). Lepszy w zadaniach technicznych (generowanie JSON-LD, robienie prostych obliczeń). Gorszy w utrzymywaniu tonu na długich tekstach — po 1 500 słowach zaczyna „zapominać" instrukcje z początku promptu.

Praktyczna implikacja: do długich artykułów — Claude z obszernym kontekstem. Do krótkich form (meta opisy, tytuły, FAQ) — ChatGPT dla szybkości.

## Czego promptem nie naprawisz

**Braku strategii.** Żaden prompt nie wymyśli za Ciebie, na jaką frazę celować i jaki format zastosować. To wymaga analizy SERP i danych z narzędzi SEO.

**Braku ekspertyzy.** Jeśli nie wiesz, o czym piszesz, AI też nie będzie wiedzieć — wyprodukuje tekst, który brzmi mądrze, ale jest pusty. Prompt engineering nie zastępuje wiedzy merytorycznej.

**Braku danych.** AI nie ma Twoich danych z Google Analytics, Twoich wyników z projektów, Twoich doświadczeń z klientami. Te dane musisz dostarczyć w prompcie albo dodać po wygenerowaniu szkicu.

**Monotonii stylistycznej na skalę.** Nawet z najlepszym promptem, 50 artykułów z tego samego modelu zacznie brzmieć podobnie. Dlatego redakcja ludzka musi wprowadzać wariancję — różne otwarcia, różne przykłady, różne perspektywy.

## FAQ

### Czy powinienem tworzyć prompty po polsku czy angielsku?

Po polsku, jeśli artykuł ma być po polsku. Modele generują lepszy tekst w docelowym języku, gdy prompt jest w tym samym języku. Prompt po angielsku + instrukcja „pisz po polsku" daje gorsze wyniki niż prompt po polsku od początku — bo model „myśli" w angielskim i tłumaczy, zamiast pisać po polsku natywnie.

### Jak długi powinien być prompt?

Dla prostego zadania (meta opis, warianty tytułu): 5–10 zdań. Dla artykułu: 200–500 słów kontekstu (rola + specyfikacja + dane + ograniczenia). Dłuższy nie znaczy lepszy — ale precyzyjniejszy znaczy lepszy. Prompt 50-wyrazowy, ale precyzyjny, daje lepsze wyniki niż prompt 500-wyrazowy, ale chaotyczny.

### Czy warto budować bibliotekę promptów?

Tak — to jedna z najcenniejszych inwestycji czasu. Stwórz dokument z promptami dla: otwarcia artykułu (3 warianty), sekcji H2, FAQ, meta tytułu, meta opisu, przeformułowania, weryfikacji. Gdy prompt działa dobrze — zapisz go. Gdy zawodzi — modyfikuj i testuj. Po 2–3 miesiącach masz bibliotekę, która skraca czas promptowania z 10 minut do 2 minut na artykuł.

### Czy ten sam prompt daje te same wyniki za każdym razem?

Nie — modele AI mają element losowości (tzw. temperature). Ten sam prompt może dać nieco inny tekst przy każdym użyciu. To zaleta, nie wada — pozwala generować warianty. Jeśli chcesz bardziej powtarzalnych wyników, dodaj więcej ograniczeń w prompcie (dokładna struktura, dokładna długość, konkretne dane do użycia).

### Jak testować, czy prompt jest dobry?

Użyj go 5 razy i oceń wyniki. Jeśli 4 z 5 szkiców wymagają mniej niż 30 minut redakcji — prompt jest dobry. Jeśli 3 z 5 wymagają przepisania — prompt wymaga poprawy. Mierzalna metryka: czas redakcji po wygenerowaniu szkicu. Dobry prompt = krótka redakcja. Zły prompt = długa redakcja lub pisanie od zera.
