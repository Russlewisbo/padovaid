# Padovaid Project — File Rename & Cleanup Plan
**Prepared:** 2026-04-05  
**Status:** FINALIZED — Ready for implementation.

---

## Naming Convention Adopted

| Category | Convention | Example |
|---|---|---|
| QMD source files | `topic-type.qmd` (all lowercase, kebab-case) | `fuo-slides.qmd` |
| Image folders | `images-topic/` (all lowercase, hyphen) | `images-fuo/` |
| Bibliography files | `refs-topic.bib` (all lowercase, hyphen) | `refs-fuo.bib` |

---

## Section 1: Image Folders

| # | Current Name | New Name | Notes |
|---|---|---|---|
| 1 | `images/` | `images-fuo/` | FUO slide images (bacteria.png in FUO.qmd title) |
| 2 | `images_immune/` | `images-immunocompromise-slides/` | Immunocompromise slide images |
| 3 | `images_malaria/` | `images-malaria/` | Malaria images |
| 4 | `images3/` | `images-diarrhea-slides/` | Diarrhea slide images |
| 5 | `images-febrileneutropenia/` | `images-febrile-neutropenia/` | Add hyphen for readability |
| 6 | `images-immunocompromise/` | `images-immunocompromise-webpage/` | Used by chapter-immunocompromise.qmd (74 files) |
| 7 | `immunocompromise-images/` | `images-immunocompromise-extra/` | NOT referenced in any QMD; has 6 extra files vs #6; archive |
| 8 | `intraabdominal_images1/` | `images-intraabdominal-1/` | Fix underscore, reorder prefix |
| 9 | `intraabdominla_images2/` | `images-intraabdominal-2/` | TYPO FIX + reorder prefix |
| 10 | `FUO_images/` | `images-fuo-webpage/` | FUO webpage images |
| 11 | `diarrhea-webpage-images/` | `images-diarrhea-webpage/` | Reorder prefix |

---

## Section 2: Bibliography Files

| # | Current Name | New Name | Notes |
|---|---|---|---|
| 1 | `FUO_references.bib` | `refs-fuo.bib` | Used by FUO_chapter-webpage.qmd |
| 2 | `Diarrhea.bib` | `refs-diarrhea-slides.bib` | Older diarrhea bib (42.9K) |
| 3 | `diarrhea-references.bib` | `refs-diarrhea.bib` | Used by diarrhea-webpage.qmd; in _quarto.yml |
| 4 | `Malaria.bib` | `refs-malaria-slides.bib` | Older malaria bib |
| 5 | `references-malaria-page.bib` | `refs-malaria.bib` | Used by chapter-webpage.qmd |
| 6 | `references-febrile.bib` | `refs-febrile-neutropenia.bib` | Used by chapter-febrile.qmd |
| 7 | `references-immunocompromise.bib` | `refs-immunocompromise.bib` | Used by immunosuppression.qmd + chapter-immunocompromise.qmd |
| 8 | `references-intraabdom1.bib` | `refs-intraabdominal-1.bib` | Used by chapter-1-webpage.qmd |
| 9 | `references_pt2.bib` | `refs-intraabdominal-2.bib` | Used by chapter2-webpage.qmd + chapter-slides.qmd; in _quarto.yml |
| 10 | `references.bib` | `refs-general.bib` | Used by chapter-slides.qmd + intraabdominal1-slides.qmd |

---

## Section 3: QMD Files

### 3a. Landing Pages (sidebar in _quarto.yml)

| # | Current Name | New Name | Notes |
|---|---|---|---|
| 1 | `Index.qmd` | `index.qmd` | Lowercase convention |
| 2 | `Antibiotic.qmd` | `antibiotic-principles.qmd` | |
| 3 | `Allergies.qmd` | `allergies.qmd` | |
| 4 | `Intraabdominal.qmd` | `intraabdominal.qmd` | |
| 5 | `immunosuppression.qmd` | `immunosuppression.qmd` | KEEP AS-IS |
| 6 | `febrileneutropenia.qmd` | `febrile-neutropenia.qmd` | |
| 7 | `Diarrheapage.qmd` | `diarrhea.qmd` | Drop redundant "page" suffix |
| 8 | `Malariapage.qmd` | `malaria.qmd` | Drop redundant "page" suffix |

### 3b. Full Content Webpages

| # | Current Name | New Name | Topic |
|---|---|---|---|
| 9 | `chapter-webpage.qmd` | `malaria-webpage.qmd` | Malaria |
| 10 | `chapter-1-webpage.qmd` | `intraabdominal-1-webpage.qmd` | Intra-abdominal Part 1 |
| 11 | `chapter2-webpage.qmd` | `intraabdominal-2-webpage.qmd` | Intra-abdominal Part 2 |
| 12 | `FUO_chapter-webpage.qmd` | `fuo-webpage.qmd` | Fever of Unknown Origin |
| 13 | `diarrhea-webpage.qmd` | `diarrhea-webpage.qmd` | KEEP AS-IS |
| 14 | `chapter-immunocompromise.qmd` | `immunocompromise-webpage.qmd` | Immunocompromised Host |
| 15 | `chapter-febrile.qmd` | `febrile-neutropenia-webpage.qmd` | Febrile Neutropenia |
| 16 | `_diarrhea-content.qmd` | `_diarrhea-content.qmd` | KEEP AS-IS — included module |

### 3c. Slide Presentations

| # | Current Name | New Name | Topic |
|---|---|---|---|
| 17 | `Malaria.qmd` | `malaria-slides.qmd` | Malaria RevealJS slides |
| 18 | `FUO.qmd` | `fuo-slides.qmd` | FUO RevealJS slides |
| 19 | `diarrhea.qmd` | `diarrhea-slides.qmd` | Diarrhea RevealJS slides |
| 20 | `chapter-slides.qmd` | `intraabdominal-2-slides.qmd` | Intra-abdominal Part 2 |
| 21 | `intraabdominal1-slides.qmd` | `intraabdominal-1-slides.qmd` | Intra-abdominal Part 1 (add hyphen) |
| 22 | `chapter-slides_intrabdominal1.qmd` | `intraabdominal-1-slides-v2.qmd` | DIFFERENT content from #21 — older scrollable version; keep |

### 3d. Stub Pages

| # | Current Name | New Name | Notes |
|---|---|---|---|
| 23 | `Resistance.qmd` | `resistance.qmd` | Fix YAML typo (foquartormat) |
| 24 | `IFI.qmd` | `ifi.qmd` | Fix YAML typo (foquartormat) |
| 25 | `treviso.qmd` | `treviso.qmd` | KEEP AS-IS |

---

## Section 4: Files to DELETE

| File | Reason |
|---|---|
| `Immunosuppresion.qmd` | Misspelled stub; immunosuppression.qmd is the correct version |
| `Malaria2.qmd` | 35-line abandoned draft; no unique content vs Malaria.qmd |
| `Malaria2-speaker.html` | Speaker notes for deleted Malaria2.qmd |
| `chapter-draft.html` | Old rendered HTML export of immunocompromise chapter; no .qmd source |
| `chapter-draft_files/` | Dependency folder for deleted chapter-draft.html |

---

*Generated by Databot on 2026-04-05.*
