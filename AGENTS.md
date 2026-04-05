# Padovaid Project — Memory File
**Last updated:** 2026-04-05

## Project Overview
Quarto-based medical education website for infectious diseases teaching at the
University of Padua (Prof. Russell E. Lewis). Deployed to `docs/` directory.
Live site: www.padovaid.com

## Technology Stack
- **Source format:** Quarto Markdown (.qmd)
- **Build system:** Quarto with R/RStudio (`padovaid.Rproj`)
- **Output formats:** HTML website, RevealJS slides, PDF handouts, speaker notes
- **Styling:** `custom.scss`, `custom2.scss`, `styles.css`
- **Citations:** BibTeX + `diagnostic-microbiology-and-infectious-disease.csl`
- **Deployment:** Output to `docs/`, published via `_publish.yml`

---

## File Naming Conventions (standardized April 2026)

All files follow **lowercase kebab-case**:

| Category | Pattern | Example |
|---|---|---|
| QMD landing pages | `topic.qmd` | `diarrhea.qmd` |
| QMD full webpages | `topic-webpage.qmd` | `fuo-webpage.qmd` |
| QMD slide decks | `topic-slides.qmd` | `malaria-slides.qmd` |
| Image folders | `images-topic/` | `images-fuo/` |
| Bibliography files | `refs-topic.bib` | `refs-fuo.bib` |
| Included modules | `_topic-content.qmd` | `_diarrhea-content.qmd` |

---

## Active Website Structure (_quarto.yml sidebar)

| File | Topic |
|---|---|
| `index.qmd` | Home / site index |
| `antibiotic-principles.qmd` | Antibiotic principles landing page |
| `allergies.qmd` | Drug allergies landing page |
| `intraabdominal.qmd` | Intra-abdominal infections landing page |
| `immunosuppression.qmd` | Immunosuppression landing page |
| `febrile-neutropenia.qmd` | Febrile neutropenia landing page |
| `diarrhea.qmd` | Infectious diarrhea landing page |
| `malaria.qmd` | Malaria & Leishmaniasis landing page |

Global bibliography in `_quarto.yml`: `refs-diarrhea.bib`, `refs-intraabdominal-2.bib`

---

## QMD Source Files by Topic

### Fever of Unknown Origin (FUO)
- `fuo.qmd` — landing page
- `fuo-slides.qmd` — RevealJS slides
- `fuo-webpage.qmd` — full content webpage

### Malaria & Leishmaniasis
- `malaria.qmd` — landing page
- `malaria-slides.qmd` — RevealJS slides
- `malaria-webpage.qmd` — full content webpage
- `malaria-webpage-v2.qmd` — alternate version (uses different image paths; consider merging)

### Infectious Diarrhea
- `diarrhea.qmd` — landing page
- `diarrhea-slides.qmd` — RevealJS slides
- `diarrhea-webpage.qmd` — full content webpage
- `_diarrhea-content.qmd` — included content module (used by other files)

### Intra-abdominal Infections
- `intraabdominal.qmd` — landing page
- `intraabdominal-1-webpage.qmd` — Part 1: Peritonitis
- `intraabdominal-2-webpage.qmd` — Part 2: Appendicitis & Liver/Biliary
- `intraabdominal-1-slides.qmd` — Part 1 slides (polished, 1920×1080)
- `intraabdominal-1-slides-v2.qmd` — Part 1 slides (older scrollable version)
- `intraabdominal-2-slides.qmd` — Part 2 slides

### Febrile Neutropenia
- `febrile-neutropenia.qmd` — landing page
- `febrile-neutropenia-webpage.qmd` — full content webpage

### Immunocompromised Host
- `immunosuppression.qmd` — landing page
- `immunocompromise-webpage.qmd` — full content webpage

### Stubs / Other
- `antibiotic-principles.qmd` — landing page stub
- `allergies.qmd` — landing page stub
- `resistance.qmd` — stub (Antimicrobial Resistance in ESCAPE Pathogens)
- `ifi.qmd` — stub (Invasive Fungal Infections)
- `treviso.qmd` — Zoom lecture links for Treviso group

---

## Image Folders

| Folder | Used By |
|---|---|
| `images-fuo/` | `fuo-slides.qmd` (and some figures in `malaria-webpage.qmd`) |
| `images-fuo-webpage/` | `fuo-webpage.qmd` |
| `images-malaria/` | `malaria-slides.qmd`, `malaria-webpage-v2.qmd` |
| `images-diarrhea-slides/` | `diarrhea-slides.qmd` |
| `images-diarrhea-webpage/` | `diarrhea-webpage.qmd`, `_diarrhea-content.qmd` |
| `images-febrile-neutropenia/` | `febrile-neutropenia-webpage.qmd` |
| `images-immunocompromise-slides/` | Immunocompromise slide decks |
| `images-immunocompromise-webpage/` | `immunocompromise-webpage.qmd` |
| `images-immunocompromise-extra/` | Not referenced in any QMD; has 6 extra files — archive/review |
| `images-intraabdominal-1/` | Intra-abdominal Part 1 files |
| `images-intraabdominal-2/` | Intra-abdominal Part 2 files |

---

## Bibliography Files

| File | Used By |
|---|---|
| `refs-fuo.bib` | `fuo-webpage.qmd`, `fuo.qmd` |
| `refs-diarrhea.bib` | `diarrhea-webpage.qmd`; global in `_quarto.yml` |
| `refs-diarrhea-slides.bib` | Older diarrhea bib — check if still needed |
| `refs-malaria.bib` | `malaria-webpage.qmd` |
| `refs-malaria-slides.bib` | Older malaria bib — check if still needed |
| `refs-febrile-neutropenia.bib` | `febrile-neutropenia-webpage.qmd` |
| `refs-immunocompromise.bib` | `immunosuppression.qmd`, `immunocompromise-webpage.qmd` |
| `refs-intraabdominal-1.bib` | `intraabdominal-1-webpage.qmd` |
| `refs-intraabdominal-2.bib` | `intraabdominal-2-webpage.qmd`, `intraabdominal-2-slides.qmd`; global in `_quarto.yml` |
| `refs-general.bib` | `intraabdominal-2-slides.qmd`, `intraabdominal-1-slides.qmd` |

---

## Supporting Assets (root level)
- `translate.html` — Google Translate widget; included in every page via `_quarto.yml`
- `custom.scss`, `custom2.scss`, `styles.css` — site styling
- `diagnostic-microbiology-and-infectious-disease.csl` — citation style
- `800-unipd.png/svg`, `University_of_Padua_seal.svg` — institutional branding
- `_extensions/fontawesome/` — FontAwesome icon support for slides

## Items Needing Future Attention
- **`malaria-webpage.qmd` vs `malaria-webpage-v2.qmd`**: Two versions of the malaria webpage differing in image paths; consider merging into one
- **`images-immunocompromise-extra/`**: Not referenced by any QMD; 6 unique images — review and either incorporate or delete
- **`refs-diarrhea-slides.bib`** and **`refs-malaria-slides.bib`**: Older bibs; verify whether any QMD still needs them

## Build Command
```bash
quarto render
```
Output goes to `docs/`.
