// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)
#import "@preview/fontawesome:0.5.0": *

#set page(
  paper: "us-letter",
  margin: (x: 2cm,y: 2.5cm,),
  numbering: "1",
)

#show: doc => article(
  title: [Infectious Diarrhea],
  subtitle: [Clinical Lecture Notes],
  authors: (
    ( name: [Prof.~Russell E. Lewis, University of Padua],
      affiliation: [],
      email: [] ),
    ),
  date: [2026-05-05],
  toc: true,
  toc_title: [Table of contents],
  toc_depth: 2,
  cols: 1,
  doc,
)

= Introduction and Overview
<introduction-and-overview>
Gastroenteritis represents one of the most prevalent infectious disease syndromes encountered in clinical practice worldwide. The global burden of enteric infections is staggering, with an estimated 4.5 billion episodes occurring annually across all populations. This immense disease burden reflects the ubiquitous nature of pathogens affecting the gastrointestinal tract and the challenges posed by inadequate sanitation, unsafe food and water supplies, and limited access to effective preventive measures in many regions.

The clinical presentation of infectious diarrhea varies considerably depending on the involved pathogen and the host's immune status. A fundamental distinction exists between two major pathophysiologic categories: inflammatory (or dysenteric) diarrhea and noninflammatory diarrhea. This classification has profound implications for diagnosis, treatment, and clinical management.

Noninflammatory diarrhea typically results from secretory mechanisms or osmotic effects caused by pathogens that do not directly invade or damage the intestinal epithelium. Such infections commonly present with watery stools, minimal abdominal cramping, and the characteristic absence of blood or inflammatory cells in stool samples. In contrast, inflammatory diarrhea involves direct mucosal invasion or toxin-mediated damage, leading to the presence of blood, mucus, and leukocytes in stool. This distinction guides both diagnostic approach and empiric management decisions.

#block[
#callout(
body: 
[
The presence of fever in combination with visible blood in the stool strongly suggests inflammatory diarrhea caused by invasive pathogens such as Salmonella, Shigella, Campylobacter, or enteroinvasive Escherichia coli. This clinical presentation should prompt evaluation for bacterial pathogens and consideration of antimicrobial therapy, whereas uncomplicated noninflammatory diarrhea often resolves without specific antimicrobial agents.

]
, 
title: 
[
Clinical Pearl: Distinguishing Inflammatory from Noninflammatory Diarrhea
]
, 
background_color: 
rgb("#f7dddc")
, 
icon_color: 
rgb("#CC1914")
, 
icon: 
fa-exclamation()
, 
body_background_color: 
white
)
]
= Epidemiology of Acute Noninflammatory Diarrhea
<epidemiology-of-acute-noninflammatory-diarrhea>
The epidemiologic burden of acute diarrheal disease remains enormous despite advances in prevention and treatment. According to recent global health assessments, acute diarrheal illnesses resulted in approximately 1.6 million deaths globally in 2016, making diarrhea the eighth leading cause of death worldwide #cite(<Troeger2018>, form: "prose");. This mortality burden disproportionately affects children younger than five years of age, with the vast majority of these deaths occurring in low- and middle-income countries in sub-Saharan Africa and South Asia #cite(<Liu2016>, form: "prose");.

== Differential Disease Burden by Geographic Region
<differential-disease-burden-by-geographic-region>
The pathogen-attributable burden of diarrheal disease varies significantly across geographic regions, reflecting differences in sanitation infrastructure, water quality, food safety practices, and healthcare access. In resource-abundant nations, enteroviruses and noroviruses predominate as etiologic agents. In contrast, less developed regions continue to experience substantial morbidity from bacterial pathogens, particularly enterotoxigenic E. coli (ETEC), Campylobacter jejuni, and non-typhoidal Salmonella species. The contribution of specific pathogens also varies seasonally, with viral pathogens showing winter predominance in temperate climates and less pronounced seasonality in tropical regions.

== Vulnerable Populations
<vulnerable-populations>
Children under five years of age experience disproportionate disease burden, accounting for the majority of diarrhea-attributable mortality. In this population, severe dehydration and electrolyte abnormalities represent the primary life-threatening complications. Certain populations, including travelers to endemic regions, immunocompromised individuals, and residents of congregate living facilities, face substantially elevated risk for both acquisition and severe disease progression.

= Community-Acquired Diarrhea
<community-acquired-diarrhea>
== Acute Pediatric Diarrhea
<acute-pediatric-diarrhea>
=== Weanling Diarrhea and Infants
<weanling-diarrhea-and-infants>
The period of transition from exclusive breastfeeding to other sources of nutrition (six to twenty-four months of age) represents a vulnerable time for diarrheal disease. The introduction of contaminated complementary foods, combined with declining passive immunity from breast milk, creates conditions favorable for infection. This period, termed the "weanling diarrhea" phase, accounts for substantial morbidity and mortality in resource-limited settings.

The protective effects of breastfeeding are well-established and multifactorial, resulting from both immunologic components (including secretory IgA, lactoferrin, and other antimicrobial proteins) and the hygiene benefits of direct nursing without intermediate contamination. Exclusive breastfeeding for the first six months of life substantially reduces the incidence and severity of infectious diarrhea.

=== Seasonality and Temporal Patterns
<seasonality-and-temporal-patterns>
Diarrheal disease in pediatric populations demonstrates characteristic seasonal patterns, particularly in temperate climates where viral pathogens predominate during winter months. In tropical and subtropical regions, the seasonality is less pronounced or follows different patterns influenced by rainfall, temperature, and cultural practices affecting water and food safety.

== Diarrhea in Adult Populations
<diarrhea-in-adult-populations>
Adult presentations of community-acquired diarrhea reflect different pathogen epidemiology compared to children. Noroviruses represent the most frequently identified cause of acute gastroenteritis in adults in resource-abundant settings, accounting for substantial numbers of outbreaks in closed environments such as hospitals, cruise ships, and long-term care facilities. The burden of norovirus disease in adults is substantial yet often underappreciated due to the general self-limiting nature of the illness.

Clostridioides difficile infection has emerged as an increasingly important cause of diarrhea in adult populations, particularly in healthcare settings but also in community settings. The epidemiology of C. difficile-associated disease continues to evolve, with increases in severity and recurrence noted in recent years.

Foodborne outbreaks attributable to Salmonella species remain common in developed nations, frequently associated with contaminated poultry products, eggs, and other animal-derived foods. Such outbreaks highlight the ongoing challenge of maintaining food safety even in industrialized countries with substantial regulatory oversight.

= Viral Pathogens
<viral-pathogens>
== Rotavirus
<rotavirus>
Rotavirus represents the most significant viral cause of severe diarrhea in young children worldwide, despite the introduction and implementation of rotavirus vaccines in many countries #cite(<Parashar2006>, form: "prose");. Prior to the vaccine era, rotavirus accounted for the vast majority of hospitalizations for severe diarrhea in infants and young children across all economic strata. Even in the post-vaccine era, rotavirus continues to cause substantial disease burden, particularly in regions where vaccine coverage remains suboptimal.

=== Epidemiology and Clinical Burden
<epidemiology-and-clinical-burden>
Rotavirus causes an estimated 100 million or more cases annually in children worldwide, with approximately 150,000 deaths occurring in children under five years of age #cite(<Tate2012>, form: "prose");. The disease presents typically with acute watery diarrhea, vomiting, fever, and abdominal discomfort. The illness is generally self-limiting but carries substantial risk for dehydration in young children.

=== Virology and Classification
<virology-and-classification>
Rotavirus belongs to the family Reoviridae and exists in multiple serotypes designated A through E (groups A through E). The virus exhibits two major classification systems: the G-type system, based on the variable outer capsid VP7 protein, and the P-type system, based on the VP4 spike protein. These classification systems identify which glycoprotein (G-type) and which protease-sensitive protein (P-type) are present in individual strains. The most common combination in human disease is G1P\[8\], though G2P\[4\], G3P\[8\], and G4P\[8\] also cause human infection.

=== Pathophysiology
<pathophysiology>
The pathophysiologic mechanisms of rotavirus-induced diarrhea involve several key processes. The virus preferentially infects mature enterocytes in the small intestine, causing villus blunting and disruption of the normal intestinal architecture. This viral invasion and epithelial damage results in decreased surface area for nutrient absorption and reduced density of brush border enzymes involved in carbohydrate digestion. Additionally, rotavirus produces a nonstructural protein (NSP4) that functions as an enterotoxin, further contributing to secretory fluid losses. The combined effects of epithelial damage, enzyme deficiency, and enterotoxin activity result in substantial watery diarrhea and the characteristic clinical syndrome.

#figure([
#box(image("images-diarrhea-webpage/Screenshot 2026-03-20 105308.png", width: 60.0%))
], caption: figure.caption(
position: bottom, 
[
Rotavirus pathophysiology: villus blunting, brush-border enzyme deficiency, and NSP4 enterotoxin activity combine to produce watery diarrhea.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-rotavirus-pathophys>


=== Vaccines
<vaccines>
Two rotavirus vaccines have been licensed and implemented in immunization programs worldwide #cite(<Vesikari2006>, form: "prose");; #cite(<Ruiz-Palacios2006>, form: "prose");. RotaTeq (manufactured by Merck) is a pentavalent vaccine containing five reassortant rotavirus strains derived from bovine and human parent strains, providing broad protection against multiple G and P types. Rotarix (manufactured by GlaxoSmithKline) is a monovalent vaccine containing a single attenuated rotavirus strain that nonetheless provides cross-protection against multiple serotypes through mechanisms not completely understood.

#block[
#callout(
body: 
[
Rotavirus vaccines are administered orally and must be given before 32 weeks of age in the United States (RotaTeq) or before 20 weeks of age in other regions (Rotarix). The presence of severe combined immunodeficiency (SCID) represents a contraindication due to theoretical risks of vaccine-strain viral replication in the immunocompromised host. Parents should be counseled that rotavirus vaccination dramatically reduces the risk of severe gastroenteritis but does not eliminate infection entirely; breakthrough infections may still occur, typically with milder disease.

]
, 
title: 
[
Clinical Pearl: Rotavirus Vaccination
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
== Norovirus (Winter Vomiting Disease)
<norovirus-winter-vomiting-disease>
Norovirus has emerged as a leading cause of acute epidemic gastroenteritis in both children and adults, particularly in developed nations #cite(<Ahmed2014>, form: "prose");. The virus accounts for approximately one-third of all nonbacterial gastroenteritis outbreaks reported in the United States, making it the most common cause of foodborne illness outbreaks in recent years.

=== Virology and Genera
<virology-and-genera>
Noroviruses belong to the family Caliciviridae and are divided into at least four distinct genera #cite(<Patel2008>, form: "prose");. Within the genus Norovirus, multiple genogroups have been identified, with genogroups I, II, and IV predominating in human disease. The virus exhibits remarkable genetic diversity and undergoes rapid evolution, leading to the circulation of numerous distinct strains and the capacity to reinfect individuals previously exposed to different norovirus strains.

=== Epidemiology and Outbreak Characteristics
<epidemiology-and-outbreak-characteristics>
Norovirus causes explosive outbreaks in closed or semi-closed environments including hospitals, long-term care facilities, cruise ships, schools, and restaurants. The virus spreads rapidly through person-to-person transmission via aerosolized particles or contaminated fomites, leading to high attack rates within affected populations. Outbreaks demonstrate a clear winter predominance in temperate climates, corresponding to the epidemiologic pattern observed with other respiratory viral pathogens.

#figure([
#box(image("images-diarrhea-webpage/cruise.png", width: 70.0%))
], caption: figure.caption(
position: bottom, 
[
Cruise ships are a classic setting for explosive norovirus outbreaks: shared dining, confined quarters, and rapid person-to-person spread via fomites and aerosolized vomitus drive high attack rates.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-norovirus-cruise>


=== Clinical Presentation
<clinical-presentation>
The typical norovirus infection manifests with acute onset of nausea, vomiting, abdominal cramping, and watery diarrhea. The illness is notably self-limiting, typically resolving within forty-eight to seventy-two hours. Fever is variable in intensity and may be absent in some infections. The rapid onset and short duration of illness distinguish norovirus gastroenteritis from bacterial causes, which typically have longer incubation periods and more protracted courses.

=== Pathophysiology
<pathophysiology-1>
The pathophysiologic mechanisms underlying norovirus infection parallel those of rotavirus, involving epithelial invasion and damage to the brush border of the small intestine. Histologic examination reveals blunting of intestinal villi and increased cellular infiltration. The virus alters intestinal permeability and intestinal function, contributing to the secretory diarrhea characteristic of the infection.

== Sapovirus
<sapovirus>
Sapovirus ranks as the second most common cause of all-cause diarrheal disease in many community-based epidemiologic studies, particularly in pediatric populations. The virus belongs to the family Caliciviridae and shares many epidemiologic and clinical characteristics with norovirus, including the capacity for rapid person-to-person spread and frequent occurrence of outbreaks in institutional settings.

=== Clinical and Epidemiologic Features
<clinical-and-epidemiologic-features>
Sapovirus causes acute watery diarrhea, vomiting, and fever, with clinical features resembling those of rotavirus and norovirus infections. The illness is generally self-limiting with duration typically less than one week. Sapovirus demonstrates significant genotype-specific immunity, meaning that prior infection with one sapovirus genotype does not provide complete protection against infection with other genotypes, explaining the capacity of the virus to cause recurrent infections within populations.

== Other Viral Etiologies
<other-viral-etiologies>
=== Astroviruses
<astroviruses>
Astroviruses represent a less common but still clinically significant cause of acute viral gastroenteritis, particularly in young children, elderly persons, and immunocompromised individuals. The viruses belong to the family Astroviridae and are transmitted through the fecal-oral route. Astrovirus infections typically present with watery diarrhea, low-grade fever, and mild systemic symptoms. The illness is generally self-limiting within several days.

=== Enteroviruses: Adenoviruses 40 and 41
<enteroviruses-adenoviruses-40-and-41>
Enteroviruses of the species Enterovirus F, particularly serotypes Ad-40 and Ad-41, cause significant gastroenteritis in infants and young children. These non-enveloped DNA viruses were historically termed enteric adenoviruses due to their predilection for the gastrointestinal tract. They present with acute watery diarrhea, vomiting, and fever. The infections are typically self-limiting.

=== Coronaviruses
<coronaviruses>
The emergence of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) has expanded recognition of coronaviruses as enteric pathogens. While respiratory symptoms predominate in most SARS-CoV-2 infections, gastrointestinal manifestations including diarrhea occur in a substantial proportion of infected individuals. The pathophysiology involves viral entry via angiotensin-converting enzyme 2 (ACE2) receptors present on intestinal epithelial cells. Other coronaviruses have also been associated with gastroenteritis, including some strains of human coronavirus.

=== Emerging and Likely Pathogens
<emerging-and-likely-pathogens>
Bocaviruses, pestiviruses, and toroviruses have been increasingly identified in diarrheal disease through application of molecular diagnostic techniques. The clinical significance of these organisms remains incompletely characterized, and their identification may represent either primary pathogens or incidental findings in some cases.

== Viral Pathogens Causing Gastroenteritis
<viral-pathogens-causing-gastroenteritis>
#table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([Established Pathogens], [Likely and Emerging Pathogens],),
  table.hline(),
  [Adenoviruses (enteric types)], [Bocaviruses],
  [Astroviruses], [Coronaviruses (including SARS-CoV-2)],
  [Caliciviruses (including noroviruses and sapoviruses)], [Enteroviruses (various)],
  [Rotaviruses groups A--C], [Picobirnaviruses, picornaviruses],
  [Cytomegalovirus], [Pestiviruses],
  [], [Toroviruses],
  [], [Filovirus (Ebola virus)],
  [], [Human protoparvoviruses],
)
= Protozoan Pathogens
<protozoan-pathogens>
== Cryptosporidiosis
<cryptosporidiosis>
Cryptosporidium species represent the second most common cause of acute noninflammatory diarrhea worldwide #cite(<Checkley2015>, form: "prose");, surpassed only by viral pathogens. The parasite exhibits a complex lifecycle involving oocyst formation that renders it relatively resistant to environmental stresses and chlorination used in standard water treatment processes.

=== Species and Epidemiology
<species-and-epidemiology>
Two main species cause human infection: #emph[Cryptosporidium parvum] and #emph[Cryptosporidium hominis];. While #emph[\C. parvum] commonly infects both humans and animals, #emph[\C. hominis] exhibits species specificity for humans. The parasite spreads through consumption of contaminated water or food, or through direct contact with infected individuals or animals.

=== Clinical Manifestations
<clinical-manifestations>
In immunocompetent individuals, cryptosporidiosis typically presents with acute watery diarrhea, abdominal cramping, and constitutional symptoms that resolve spontaneously within one to two weeks. However, in severely immunocompromised individuals, particularly those with advanced HIV infection (CD4 count \<100 cells/μL), the infection becomes severe and protracted. Chronic diarrhea lasting months or longer can result in substantial weight loss and malnutrition. Prior to the widespread availability of effective antiretroviral therapy for HIV, cryptosporidial diarrhea represented one of the defining opportunistic infections in AIDS patients.

=== Pathophysiology
<pathophysiology-2>
Cryptosporidium organisms reside intracellularly within small intestinal epithelial cells, causing villus atrophy and mucosal damage. The mechanism involves both direct parasitic damage and host inflammatory response. The parasite is unusual among enteric protozoa in its small size and intracellular location.

=== Diagnosis and Treatment
<diagnosis-and-treatment>
Diagnosis relies on identification of oocysts in stool specimens through microscopy using special stains (such as acid-fast staining) or through antigen detection using enzyme immunoassay or immunofluorescence. Molecular diagnostic techniques using PCR have improved sensitivity and allow for species differentiation.

Treatment of cryptosporidiosis depends on the host's immune status. In immunocompetent individuals, supportive care with rehydration often suffices, as the infection typically resolves spontaneously. In immunocompromised patients, specific antiparasitic therapy becomes necessary. Nitazoxanide represents the primary antimicrobial agent #cite(<Rossignol2006>, form: "prose");, though efficacy is incomplete and prolonged or repeated courses may be required. Immune reconstitution through antiretroviral therapy in HIV-infected individuals remains crucial for long-term resolution of cryptosporidial diarrhea.

== Giardiasis
<giardiasis>
#emph[Giardia lamblia] (also known as #emph[Giardia intestinalis] or #emph[Giardia duodenalis];) ranks among the most common parasitic causes of diarrhea worldwide #cite(<Einarsson2016>, form: "prose") and represents a leading cause of chronic noninflammatory diarrhea in endemic regions.

=== Epidemiology and Transmission
<epidemiology-and-transmission>
Giardiasis demonstrates worldwide distribution with particularly high prevalence in regions with inadequate sanitation and contaminated water supplies. The parasite exists in both trophozoite and cyst forms, with the latter representing the infectious stage. Transmission occurs through consumption of water or food contaminated with cysts. Person-to-person transmission can occur through direct contact, explaining the clustering of cases in institutional settings such as daycare centers and among travelers sharing common water sources.

=== Clinical Presentation
<clinical-presentation-1>
Giardiasis frequently presents with acute onset of watery diarrhea, abdominal cramping, bloating, and malabsorption. The acute illness typically resolves spontaneously within one to two weeks. However, a substantial proportion of infected individuals develop chronic noninflammatory diarrhea characterized by intermittent loose stools, weight loss, and malabsorption lasting weeks to months. In some patients, particularly those with underlying immunoglobulin deficiencies, chronic giardiasis can persist for years without specific treatment.

=== Diagnosis
<diagnosis>
Diagnosis of giardiasis relies on identification of trophozoites or cysts in stool specimens or duodenal aspirates. Stool microscopy demonstrates variable sensitivity (approximately 60-70% with a single specimen), requiring examination of multiple specimens for adequate sensitivity. Antigen detection using ELISA or immunofluorescence assays has improved diagnostic accuracy. Serologic testing demonstrating specific antibodies may be helpful in some situations.

=== Treatment
<treatment>
Metronidazole represents the traditional first-line agent for giardiasis treatment, achieving cure rates of approximately 70% with a standard seven-day course. Alternative agents include tinidazole, which achieves higher cure rates (\>90%) with shorter duration of treatment, and nitazoxanide. The lower efficacy of metronidazole, despite decades of clinical use, has led to investigation of combination therapy or alternative regimens in cases of persistent infection.

= Bacterial Pathogens
<bacterial-pathogens>
== Mechanisms of Bacterial Diarrheal Disease
<mechanisms-of-bacterial-diarrheal-disease>
Bacterial enteropathogens cause diarrhea through two broad and partly overlapping pathways: a #strong[secretory] (toxin-mediated) mechanism that drives large-volume watery diarrhea without epithelial invasion, and an #strong[invasive/inflammatory] mechanism in which bacteria penetrate the mucosa, recruit leukocytes, and produce dysentery. Recognizing which pathway predominates guides both diagnostic workup and empiric management.

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Feature], [Secretory (toxin-mediated)], [Invasive / inflammatory],),
  table.hline(),
  [#strong[Representative pathogens];], [ETEC, #emph[Vibrio cholerae];, #emph[\C. perfringens];, #emph[\S. aureus] (preformed toxin)], [#emph[Shigella];, EIEC, non-typhoidal #emph[Salmonella];, #emph[Campylobacter jejuni];, #emph[Yersinia];],
  [#strong[Site of action];], [Small bowel], [Distal small bowel and colon],
  [#strong[Mechanism];], [Enterotoxin activates adenylate / guanylate cyclase → ↑ cAMP / cGMP → Cl⁻ and water secretion], [Bacterial invasion of enterocytes, intracellular replication, mucosal ulceration, cytokine response],
  [#strong[Stool character];], [Large-volume, watery, no blood], [Small-volume, often bloody/mucoid, fecal leukocytes present],
  [#strong[Fever];], [Absent or low-grade], [Often prominent (\>38.5 °C)],
  [#strong[Tenesmus / urgency];], [Uncommon], [Common (especially colitic pathogens)],
  [#strong[Fecal leukocytes / lactoferrin];], [Negative], [Positive],
  [#strong[Epithelial barrier];], [Intact], [Disrupted (ulceration, microabscesses)],
  [#strong[Role of antibiotics];], [Limited (rehydration is primary; abx shorten cholera/ETEC)], [Often beneficial --- except STEC, where antibiotics increase HUS risk],
)
#figure([
#box(image("images-diarrhea-webpage/ch100-007.png", width: 70.0%))
], caption: figure.caption(
position: bottom, 
[
Methylene blue stain of fecal leukocytes from a patient with colitis. This exudative response is seen in invasive/inflammatory diarrhea and is largely absent in pure toxin-mediated (secretory) disease.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-fecal-leukocytes>


== Enteropathogenic #emph[Escherichia coli]
<enteropathogenic-escherichia-coli>
#emph[Escherichia coli] encompasses multiple pathotypes, each with distinct virulence mechanisms and epidemiologic distributions #cite(<Qadri2005>, form: "prose");. The major pathogenic categories include enterotoxigenic E. coli (ETEC), enteroaggregative E. coli (EAEC), enteropathogenic E. coli (EPEC), enteroinvasive E. coli (EIEC), and Shiga toxin-producing E. coli (STEC), also known as enterohemorrhagic E. coli (EHEC).

=== Enterotoxigenic #emph[\E. coli] (ETEC)
<enterotoxigenic-e.-coli-etec>
ETEC represents the most common bacterial cause of diarrhea in travelers to developing countries and in children in resource-limited settings. The pathogen produces diarrhea through elaboration of heat-labile (LT) enterotoxins and heat-stable (ST) enterotoxins. The LT enterotoxin resembles cholera toxin in structure and mechanism, activating adenylyl cyclase and increasing intestinal cAMP levels, resulting in secretory diarrhea. The ST enterotoxins activate guanylate cyclase, leading to increased intestinal cGMP and similar secretory effects. Some strains produce only LT, some only ST, and some produce both toxins.

#figure([
#box(image("images-diarrhea-webpage/etec.png", width: 75.0%))
], caption: figure.caption(
position: bottom, 
[
ETEC pathogenesis. Heat-labile (LT) toxin activates adenylate cyclase (↑ cAMP); heat-stable (ST) toxin activates guanylate cyclase (↑ cGMP). The resulting electrolyte and water secretion produces high-volume watery diarrhea while the epithelial barrier remains intact.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-etec-mechanism>


=== Shiga Toxin-Producing #emph[\E. coli] (STEC)
<shiga-toxin-producing-e.-coli-stec>
STEC strains, particularly serotype O157:H7, cause hemorrhagic colitis characterized by bloody diarrhea without systemic toxemia #cite(<Tarr2005>, form: "prose");. The infection can progress to hemolytic-uremic syndrome (HUS), characterized by microangiopathic hemolytic anemia, thrombocytopenia, and acute kidney injury. STEC produces Shiga toxins that damage the vascular endothelium, particularly in the kidney.

#figure([
#box(image("images-diarrhea-webpage/clipboard-3152135213.jpeg", width: 70.0%))
], caption: figure.caption(
position: bottom, 
[
Pathophysiology of Shiga toxin--mediated hemolytic uremic syndrome. Shiga toxin enters the circulation, binds Gb3 receptors on glomerular endothelium, and triggers a thrombotic microangiopathy with platelet consumption, mechanical hemolysis (schistocytes), and acute kidney injury.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-hus-pathophys>


#figure([
#box(image("images-diarrhea-webpage/clipboard-4072087931.jpeg", width: 55.0%))
], caption: figure.caption(
position: bottom, 
[
Chromogenic agar for STEC: Shiga toxin--producing strains grow as mauve colonies, while other enteric bacteria appear blue, colorless, or are inhibited. Specific request to the laboratory for STEC selective media improves detection of non-O157 serotypes that are missed on routine culture.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-stec-chromogenic>


#block[
#callout(
body: 
[
The use of antibiotics in STEC infection remains controversial and potentially harmful. Evidence suggests that certain antibiotics, particularly fluoroquinolones, may increase the risk of progression to hemolytic-uremic syndrome, possibly through induction of Shiga toxin release from stressed bacteria. Current recommendations generally advise against antimicrobial therapy in uncomplicated STEC gastroenteritis and favor supportive care with careful monitoring of renal function and hemoglobin levels for development of HUS.

]
, 
title: 
[
Critical Warning: Antibiotic Avoidance in Shiga Toxin-Producing #emph[\E. coli]
]
, 
background_color: 
rgb("#fcefdc")
, 
icon_color: 
rgb("#EB9113")
, 
icon: 
fa-exclamation-triangle()
, 
body_background_color: 
white
)
]
=== Other Pathogenic #emph[\E. coli] Strains
<other-pathogenic-e.-coli-strains>
EAEC strains cause persistent diarrhea, particularly in children and immunocompromised individuals. EPEC classically caused infantile diarrhea before modern sanitation improvements and remains significant in some developing regions. EIEC exhibits invasive properties similar to Shigella species.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Serotype], [Difco Serogroup Test],),
  table.hline(),
  [O28], [C],
  [O29], [---],
  [O112], [C],
  [O124], [B],
  [O136], [C (Trabulsi 193-T-64)],
  [O143], [---],
  [O144], [---],
  [O152], [(Trabulsi 185-T-64)],
)
== #emph[Campylobacter jejuni]
<campylobacter-jejuni>
#emph[Campylobacter jejuni] represents the leading bacterial cause of gastroenteritis in many developed nations and a major cause of diarrhea worldwide #cite(<Kaakoush2015>, form: "prose");. The microorganism is a microaerophilic, curved gram-negative rod that exhibits fastidious growth requirements.

#figure([
#box(image("images-diarrhea-webpage/campylobacter.png", width: 45.0%))
], caption: figure.caption(
position: bottom, 
[
#emph[Campylobacter jejuni];: characteristic curved or S-shaped gram-negative rod. Routine stool culture media will miss it; isolation requires selective media (Campy/CCDA agar) and microaerophilic conditions.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-campylobacter-morphology>


=== Epidemiology and Sources
<epidemiology-and-sources>
The primary reservoir for #emph[\C. jejuni] is poultry, with transmission to humans occurring through consumption of contaminated poultry meat or contaminated water. The organism is increasingly recognized as a common pathogen in traveler's diarrhea.

=== Clinical Manifestations
<clinical-manifestations-1>
Campylobacteriosis typically presents with diarrhea (often bloody), fever, and abdominal cramping. The illness mimics inflammatory diarrhea clinically and histologically, with invasion and damage to the colon. The incubation period ranges from two to five days, and illness duration typically spans one week or longer.

=== Complications
<complications>
Campylobacter infection carries risk for serious complications including Guillain-Barré syndrome (GBS), a postinfectious autoimmune neuropathy that develops in a small percentage of infected individuals (approximately 1 in 1,000 infections) #cite(<Nachamkin1998>, form: "prose");. The syndrome manifests with progressive ascending paralysis and can progress to require mechanical ventilation. Recovery typically occurs over weeks to months but may be incomplete in some patients.

Reactive arthritis represents another postinfectious complication of Campylobacter infection, particularly in individuals with specific HLA genotypes.

=== Diagnosis
<diagnosis-1>
Diagnosis relies primarily on stool culture, which requires selective media favoring #emph[Campylobacter] growth. Culture sensitivity is approximately 90-95% when appropriate selective media are used. Molecular diagnostic methods have improved sensitivity and provide more rapid results.

== #emph[Salmonella] Species
<salmonella-species>
#emph[Salmonella] species cause both acute gastroenteritis (non-typhoidal salmonellosis) and systemic infections (enteric or typhoid fever caused by #emph[Salmonella typhi] and #emph[Salmonella paratyphi];) #cite(<Majowicz2010>, form: "prose");.

#figure([
#box(image("images-diarrhea-webpage/slamonella.png", width: 75.0%))
], caption: figure.caption(
position: bottom, 
[
#emph[Salmonella] spp. --- motile gram-negative Enterobacterales with more than 1,400 serotypes producing two clinically distinct syndromes: non-typhoidal gastroenteritis and enteric (typhoid/paratyphoid) fever.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-salmonella-overview>


=== Non-Typhoidal Salmonellosis
<non-typhoidal-salmonellosis>
#emph[Salmonella enteritidis] and #emph[Salmonella typhimurium] represent the most common non-typhoidal species causing human disease. The organisms are acquired through consumption of contaminated food (particularly poultry and eggs) or water. The bacteria invade the intestinal epithelium, causing inflammatory diarrhea with fever, abdominal pain, and frequently visible blood or mucus in stool.

#figure([
#box(image("images-diarrhea-webpage/turtle.png", width: 70.0%))
], caption: figure.caption(
position: bottom, 
[
Reptile-associated #emph[Salmonella] is an under-appreciated reservoir, particularly in households with pet turtles, lizards, or snakes. Children under 5 are at highest risk of invasive disease, including bacteremia and osteomyelitis.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-salmonella-turtle>


The incubation period for non-typhoidal salmonellosis typically spans six to seventy-two hours after ingestion of contaminated food. The illness is generally self-limiting, resolving within three to seven days in most immunocompetent individuals. However, bacteremia occurs in a small percentage of cases, particularly in very young children, elderly persons, and immunocompromised individuals.

=== Chronic Carrier State
<chronic-carrier-state>
A proportion of individuals who recover from acute salmonellosis develop a chronic carrier state lasting months to years. Approximately 0.6 to 2% of patients with non-typhoidal salmonellosis develop chronic fecal shedding. Chronic carriers risk transmitting infection to others and may require antimicrobial eradication therapy in some situations.

=== Typhoid Fever
<typhoid-fever>
#emph[Salmonella typhi] causes enteric fever, characterized by sustained fever, rose spots, hepatosplenomegaly, and relative bradycardia. The disease is acquired in endemic regions of South and Southeast Asia and poses a significant public health threat. Vaccination and antimicrobial prophylaxis are recommended for travelers to endemic areas.

#figure([
#box(image("images-diarrhea-webpage/ch100-009.png", width: 80.0%))
], caption: figure.caption(
position: bottom, 
[
Global distribution of typhoid and paratyphoid fever. Estimated incidence by country from the Global Burden of Disease Study 2019.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-typhoid-distribution>


#figure([
#box(image("images-diarrhea-webpage/clipboard-695628345.jpeg", width: 65.0%))
], caption: figure.caption(
position: bottom, 
[
Typhoid fever runs a stereotyped weekly course: gradual fever and bacteremia in week 1; sustained "staircase" fever, rose spots, and hepatosplenomegaly in weeks 2--3; risk of intestinal perforation and septic shock in week 3--4 if untreated.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-typhoid-progression>


#table(
  columns: (33.8%, 33.8%, 32.39%),
  align: (auto,auto,auto,),
  table.header([Category], [Clinical Feature], [Approximate Frequency],),
  table.hline(),
  [#strong[Flulike symptoms];], [Fever], [\>95%],
  [], [Headache], [80%],
  [], [Chills], [40%],
  [], [Cough], [30%],
  [], [Myalgia], [20%],
  [], [Arthralgia], [\<5%],
  [#strong[Abdominal symptoms];], [Anorexia], [50%],
  [], [Abdominal pain], [30%],
  [], [Diarrhea], [20%],
  [], [Constipation], [20%],
  [#strong[Physical findings];], [Coated tongue], [50%],
  [], [Hepatomegaly], [10%],
  [], [Splenomegaly], [10%],
  [], [Abdominal tenderness], [5%],
  [], [Rash], [\<5%],
  [], [Generalized adenopathy], [\<5%],
)
== #emph[Shigella] Species
<shigella-species>
#emph[Shigella] causes bacillary dysentery, characterized by bloody diarrhea with abundant leukocytes and mucus in stool #cite(<Kotloff2018>, form: "prose");. The four serogroups (#emph[Shigella dysenteriae];, #emph[Shigella flexneri];, #emph[Shigella boydii];, and #emph[Shigella sonnei];) differ in epidemiology and severity, with #emph[\S. dysenteriae] producing Shiga toxin and causing the most severe disease.

=== Epidemiology and Pathophysiology
<epidemiology-and-pathophysiology>
Humans represent the only known reservoir for Shigella species. The organism spreads through the fecal-oral route and exhibits a very low infectious dose (as few as 10-100 organisms can cause infection). Transmission occurs readily in conditions of crowding and poor sanitation, explaining the frequent occurrence of shigellosis in childcare settings, prisons, and developing countries.

The pathophysiology involves bacterial invasion of the colonic mucosa, intracellular multiplication, and spread to adjacent cells. The process results in abscess formation and ulceration of the mucosal surface, manifesting clinically as bloody diarrhea.

=== Clinical Features and Treatment
<clinical-features-and-treatment>
Shigellosis presents with fever, tenesmus, and bloody diarrhea with abundant fecal leukocytes. The illness is typically self-limiting, lasting three to seven days. However, antimicrobial therapy shortens illness duration and reduces transmission risk.

Current first-line antimicrobial choices for shigellosis include fluoroquinolones such as ciprofloxacin or ceftriaxone, as resistance to older agents including ampicillin and trimethoprim-sulfamethoxazole has become widespread. Susceptibility testing guides therapy in regions with emerging resistance to fluoroquinolones.

== #emph[Vibrio cholerae]
<vibrio-cholerae>
#emph[Vibrio cholerae] produces severe secretory diarrhea termed cholera #cite(<Sack2004>, form: "prose");; #cite(<Ali2015>, form: "prose");, a disease that remains endemic in South Asia, particularly Bangladesh and parts of India. The bacterium has caused seven recognized pandemics, with the current seventh pandemic having begun in 1961 with spread to multiple continents.

#figure([
#box(image("images-diarrhea-webpage/john snow.png", width: 70.0%))
], caption: figure.caption(
position: bottom, 
[
John Snow's 1854 mapping of cholera cases around the Broad Street pump in London is widely regarded as the founding investigation of modern epidemiology, demonstrating water-borne transmission decades before the causative organism was identified.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-john-snow>


=== Clinical Features
<clinical-features>
Cholera presents with acute onset of profuse watery diarrhea described characteristically as "rice-water stools" due to the appearance of the stool resembling rice water. Patients may lose several liters of stool per hour during peak illness, leading to severe dehydration, hypovolemic shock, and death if fluid losses are not replaced. Vomiting frequently accompanies the diarrhea. Fever is typically absent.

#figure([
#box(image("images-diarrhea-webpage/rice_water_stool.png", width: 60.0%))
], caption: figure.caption(
position: bottom, 
[
Characteristic "rice-water" stool of cholera: clear, watery, electrolyte-rich fluid with mucus flecks and minimal cellular debris, reflecting massive small-bowel secretion driven by cholera toxin without epithelial invasion.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-rice-water>


=== Pathophysiology
<pathophysiology-3>
#emph[Vibrio cholerae] produces cholera toxin, an A-B enterotoxin that activates adenylyl cyclase through ADP-ribosylation of the Gs protein. The resulting increases in cAMP lead to massive secretion of chloride and water into the intestinal lumen, producing the characteristic secretory diarrhea. The toxin acts on the entire small intestine, explaining the enormous volume of stool output.

=== Treatment
<treatment-1>
The primary therapeutic intervention in cholera consists of aggressive fluid and electrolyte replacement. Oral rehydration with solutions containing glucose and sodium is effective in most cases and reduces mortality dramatically. Antimicrobial therapy with agents such as tetracycline or fluoroquinolones shortens the duration of diarrhea and reduces the volume of fluid losses. Vaccination with oral cholera vaccines provides partial protection in endemic regions.

= Travel-Associated Diarrhea
<travel-associated-diarrhea>
#figure([
#box(image("images-diarrhea-webpage/suitcase.png", width: 35.0%))
], caption: figure.caption(
position: bottom, 
[
Traveler's diarrhea affects 300--500 million travelers each year, with attack rates ranging from 5% to 50% depending on destination. Onset is typically 5--15 days after arrival in an endemic region, and most episodes resolve within 1--5 days.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-travelers-suitcase>


Diarrhea affecting travelers to developing countries represents a substantial cause of morbidity and disruption of travel plans #cite(<Steffen2015>, form: "prose");; #cite(<Riddle2017>, form: "prose");. The incidence of traveler's diarrhea ranges from 5% to 50% depending on the destination, with highest risks in developing countries with poor sanitation and food safety practices. Travelers to Latin America, Africa, the Middle East, and Asia face substantially elevated risk compared to those visiting developed nations.

== Etiology and Epidemiology
<etiology-and-epidemiology>
The microbiologic causes of traveler's diarrhea vary geographically but follow some consistent patterns. Enterotoxigenic #emph[\E. coli] (ETEC) remains the most common bacterial cause, accounting for approximately 40-50% of identified bacterial pathogens. Other significant bacterial causes include #emph[Campylobacter jejuni];, non-typhoidal #emph[Salmonella];, and #emph[Shigella];. Viral pathogens, particularly noroviruses and rotavirus, contribute substantially to traveler's diarrhea epidemiology in some settings. Parasitic causes including #emph[Giardia lamblia] and #emph[Cryptosporidium] account for a smaller but clinically important proportion of cases, particularly when diarrhea persists beyond initial acute illness.

== Etiology of Acute Traveler's Diarrhea
<etiology-of-acute-travelers-diarrhea>
#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Pathogen Category], [Specific Agents], [Approximate Frequency],),
  table.hline(),
  [#strong[Bacterial (40-60%)];], [ETEC, Campylobacter, Salmonella, Shigella], [Most common overall],
  [#strong[Viral (5-15%)];], [Norovirus, Rotavirus, Other enteroviruses], [Variable by season/location],
  [#strong[Parasitic (3-5%)];], [Giardia, Cryptosporidium, Entamoeba], [More common in persistent diarrhea],
  [#strong[Unidentified (20-50%)];], [Unknown pathogens], [No organism identified],
)
#table(
  columns: (25%, 25%, 25%, 25%),
  align: (auto,auto,auto,auto,),
  table.header([Characteristic], [Latin America], [Africa], [Asia],),
  table.hline(),
  [Duration of stay (days)], [21 (2--42)], [28 (28--35)], [(28--42)],
  [Attack rate (%)], [52 (21--100)], [54 (36--62)], [(39--57)],
  [#strong[Organism (%)];], [], [], [],
  [No bacterial pathogen], [28], [---], [35],
  [Bacterial pathogen], [72], [---], [80],
  [Enterotoxigenic #emph[\E. coli];], [46 (28--72)], [36 (31--75)], [15 (5--25)],
  [Enteroaggregative #emph[\E. coli];], [30 (25--35)], [\<5], [17 (15--25)],
  [#emph[Shigella];], [5 (0--30)], [5 (0--15)], [5 (4--15)],
  [#emph[Salmonella];], [\<5], [10 (5--15)], [10 (5--15)],
  [#emph[Campylobacter jejuni];], [\<5], [\<5], [15 (2--35)],
  [#emph[Vibrio parahaemolyticus];], [---], [---], [7 (1--13)],
  [Rotavirus], [23 (0--36)], [10 (5--15)], [5 (0--15)],
  [Norovirus], [10], [---], [3],
  [Protozoa (#emph[Giardia];, #emph[Cryptosporidium];, #emph[Entamoeba histolytica];, others)], [7], [\<5], [11],
)
== Prevention Strategies
<prevention-strategies>
Prevention of traveler's diarrhea involves careful attention to food and water safety. Travelers should consume only bottled or boiled water, avoid ice made from untreated water, eat foods that are cooked hot, avoid raw vegetables and fruits that cannot be peeled, and avoid dairy products and foods kept at ambient temperature. Despite careful food precautions, some cases of traveler's diarrhea remain inevitable.

#figure([
#box(image("images-diarrhea-webpage/street_food.png", width: 60.0%))
], caption: figure.caption(
position: bottom, 
[
Street food and unpasteurized dairy are common exposures in high-risk destinations. Counsel travelers to choose foods served piping hot, peel their own fruit, and avoid ice and tap water --- including water used to rinse glasses and utensils.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-street-food>


Antimicrobial chemoprophylaxis can reduce the incidence of traveler's diarrhea in travelers with high-risk circumstances, though the practice is controversial due to concerns about adverse effects and antimicrobial resistance development. Bismuth subsalicylate taken three to four times daily provides modest protection against traveler's diarrhea, reducing incidence by approximately 50%.

== Empiric Self-Treatment
<empiric-self-treatment>
Travelers to high-risk destinations should be provided with antimicrobial agents for empiric self-treatment of diarrhea that develops during travel. Azithromycin has become the preferred first-line agent due to high efficacy against ETEC and other major pathogens #cite(<DuPont2009>, form: "prose");. A three-day course of azithromycin (500 mg daily) typically resolves traveler's diarrhea within one to two days. Fluoroquinolones such as ciprofloxacin represent alternative agents, though resistance is increasingly common in some geographic regions. Loperamide may provide symptomatic relief of cramping but should be avoided in bloody diarrhea or severe infections.

= Diarrhea in Immunocompromised Patients
<diarrhea-in-immunocompromised-patients>
Severely immunocompromised patients experience substantially different epidemiology, severity, and natural history of diarrheal disease compared to immunocompetent individuals.

== Diarrhea in HIV/AIDS
<diarrhea-in-hivaids>
Diarrhea occurs in 30-60% of individuals with AIDS (CD4 count \<200 cells/μL) #cite(<Sanchez2005>, form: "prose") and represents one of the major causes of morbidity in this population. The spectrum of pathogens causing diarrhea in AIDS patients differs from that in immunocompetent individuals, with opportunistic pathogens becoming predominant as the CD4 count declines.

=== Pathogens in Advanced HIV Infection
<pathogens-in-advanced-hiv-infection>
#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Pathogen], [CD4 Threshold], [Characteristics],),
  table.hline(),
  [#strong[Cryptosporidium];], [\<200], [Chronic, severe; may resolve with immune reconstitution],
  [#strong[Microsporidium];], [\<100], [Chronic diarrhea, malabsorption],
  [#strong[Mycobacterium avium complex];], [\<50], [Systemic infection with GI involvement],
  [#strong[Cytomegalovirus];], [\<50], [Ulcerative disease, perforation risk],
  [#strong[Histoplasma];], [\<50], [Disseminated disease with GI involvement],
  [#strong[Isospora];], [Variable], [Chronic diarrhea, tropical distribution],
)
#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Pathogen], [% With Diarrhea (#emph[n] = 181)], [% With No Diarrhea (#emph[n] = 28)],),
  table.hline(),
  [Cytomegalovirus], [12--45], [15],
  [#emph[Cryptosporidium];], [14--30], [0],
  [Microsporidia], [7.5--33], [0],
  [#emph[Entamoeba histolytica];], [0--15], [0],
  [#emph[Giardia lamblia];], [2--15], [5],
  [#emph[Salmonella] spp.], [0--15], [0],
  [#emph[Campylobacter] spp.], [2--11], [8],
  [#emph[Shigella] spp.], [5--10], [0],
  [#emph[Clostridioides difficile] toxin], [6--7], [0],
  [#emph[Vibrio parahaemolyticus];], [4], [0],
  [#emph[Mycobacterium] spp.], [2--25], [0],
  [#emph[Cystoisospora belli];], [2--6], [0],
  [#emph[Cyclospora];], [0--11], [0],
  [#emph[Blastocystis hominis];], [2--15], [16],
  [#emph[Candida albicans];], [6--53], [24],
  [Herpes simplex], [5--18], [40],
  [#emph[Chlamydia trachomatis];], [11], [13],
  [#emph[Strongyloides];], [0--6], [0],
  [Intestinal spirochetes], [11], [11],
  [#strong[One or more pathogens];], [#strong[55--86];], [#strong[39];],
)
=== Cryptosporidia in AIDS
<cryptosporidia-in-aids>
#emph[Cryptosporidium] species represent the most common parasitic cause of diarrhea in AIDS patients, particularly in those with CD4 counts below 200 cells/μL. Chronic, severe diarrhea results from massive fecal shedding of oocysts. The infection is frequently refractory to antimicrobial therapy unless immune reconstitution occurs. Nitazoxanide provides partial clinical improvement in some patients but cannot reliably achieve parasitologic cure without immune recovery.

=== Microsporidia
<microsporidia>
Microsporidia, particularly #emph[Enterocytozoon bieneusi];, cause chronic diarrhea and malabsorption in advanced AIDS patients. The organisms infect intestinal epithelial cells and produce diarrhea through mechanisms involving epithelial damage and alteration of intestinal permeability.

=== Cytomegalovirus Colitis
<cytomegalovirus-colitis>
Cytomegalovirus (CMV) causes ulcerative disease of the colon and terminal ileum in patients with CD4 counts below 50 cells/μL. The infection manifests with bloody diarrhea, abdominal pain, and risk of colonic perforation. Diagnosis requires colonoscopy with biopsy demonstrating CMV inclusions. Treatment with ganciclovir or foscarnet is indicated to prevent perforation and death.

=== Immune Reconstitution
<immune-reconstitution>
The introduction of effective antiretroviral therapy has dramatically altered the epidemiology of opportunistic diarrheal diseases in HIV-infected individuals. As CD4 counts recover with antiretroviral therapy, the risk for opportunistic infections decreases, and many chronic infections (such as cryptosporidial diarrhea) resolve spontaneously through immune reconstitution without need for specific antiparasitic therapy.

== Diarrhea in Solid Organ and Hematopoietic Stem Cell Transplant Recipients
<diarrhea-in-solid-organ-and-hematopoietic-stem-cell-transplant-recipients>
Transplant recipients experience elevated risk for diarrheal disease due to profound immunosuppression during the early post-transplant period and chronic immunosuppression to prevent rejection.

=== #emph[Clostridioides difficile] in Transplant Recipients
<clostridioides-difficile-in-transplant-recipients>
#emph[Clostridioides difficile] infection occurs at high rates in both solid organ transplant (SOT) recipients (approximately 9-20% of some SOT cohorts) and hematopoietic stem cell transplant (HSCT) recipients. Risk factors include antimicrobial therapy, intensive care unit stay, and severity of immunosuppression. CDI can present with severe, fulminant colitis in transplant recipients, requiring aggressive management.

=== Viral Pathogens in Transplant Recipients
<viral-pathogens-in-transplant-recipients>
Norovirus causes diarrheal disease in transplant recipients with particular frequency, and infected transplant recipients demonstrate prolonged viral shedding in stool compared to immunocompetent individuals. Some transplant recipients shed norovirus for weeks to months, complicating hospital epidemiology and infection control.

= Diarrhea in Institutional Settings
<diarrhea-in-institutional-settings>
Diarrheal outbreaks in institutional settings represent a substantial public health challenge and cause significant morbidity and healthcare costs.

== Hospitals
<hospitals>
#emph[Clostridioides difficile] represents the most common nosocomial cause of infectious diarrhea in hospitalized patients #cite(<Lessa2015>, form: "prose");; #cite(<McDonald2018>, form: "prose");. Risk factors include hospitalization, advanced age, and antimicrobial exposure. CDI rates have increased dramatically over the past two decades, driven in part by the emergence of hypervirulent strains.

Other nosocomial pathogens include rotavirus and norovirus, which spread readily in healthcare settings and can lead to ward closures and substantial infection control measures.

== Long-Term Care Facilities
<long-term-care-facilities>
Long-term care facility residents experience substantially elevated rates of diarrheal disease due to multiple factors including immunosenescence, multiple comorbidities, frequent antimicrobial exposure, and the congregate living environment. Rotavirus, norovirus, and #emph[\C. difficile] cause the majority of infectious outbreaks in long-term care facilities.

== Daycare Centers
<daycare-centers>
Daycare centers serve as amplification sites for transmissible diarrheal pathogens, particularly rotavirus (in the pre-vaccine era) and #emph[Giardia lamblia];. The fecal-oral transmission route, combined with the low infectious dose required for many pathogens and the hygiene challenges inherent in caring for young children, create ideal conditions for pathogen spread.

= Treatment of Acute Noninflammatory Diarrhea
<treatment-of-acute-noninflammatory-diarrhea>
The management of acute diarrheal disease follows general principles applicable to most cases, with specific modifications based on the presumed or confirmed etiology, the severity of illness, and the host's immune status.

== Rehydration: The Cornerstone of Management
<rehydration-the-cornerstone-of-management>
Rehydration represents the fundamental and most important therapeutic intervention in virtually all cases of acute diarrhea #cite(<Munos2010>, form: "prose");. The goal of rehydration therapy is to replace fluid and electrolyte losses and restore euvolemia. The choice between oral rehydration solution (ORS) and intravenous rehydration depends on the severity of dehydration, the ability to tolerate oral intake, and the clinical setting.

#block[
#callout(
body: 
[
Oral rehydration solution containing a 1:1 molar ratio of glucose to sodium (approximately 75 mEq/L sodium and 75 mmol/L glucose) achieves optimal absorption through coupled sodium-glucose transport. The World Health Organization and UNICEF recommend a low-osmolarity ORS containing sodium chloride (75 mmol/L), potassium chloride (20 mmol/L), glucose (75 mmol/L), and bicarbonate (65 mmol/L). This formulation reduces stool output compared to the previous standard ORS and decreases the incidence of hypernatremia.

]
, 
title: 
[
Management Principle: Oral Rehydration Solutions
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
#figure([
#box(image("images-diarrhea-webpage/ORS.png", width: 60.0%))
], caption: figure.caption(
position: bottom, 
[
WHO low-osmolarity oral rehydration solution exploits intact sodium--glucose cotransport (SGLT1) in the small bowel: glucose drives sodium uptake, water follows osmotically, and stool volume falls. ORS is effective for \>90% of acute diarrhea cases and is the single most cost-effective intervention in global child health.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-ors>


Oral rehydration is preferred for mild to moderate dehydration in most patients, as it is effective, less invasive, and less costly than intravenous rehydration. Patients with severe dehydration, hypotension, altered mental status, or inability to tolerate oral intake require intravenous fluid administration. Nasogastric tube administration of ORS offers an alternative for patients who cannot tolerate oral intake but do not require intravenous therapy.

== Antimicrobial Therapy
<antimicrobial-therapy>
The role of antimicrobial therapy in acute diarrhea remains controversial and depends on the presumed etiology and severity. Antimicrobial therapy is indicated for bacterial dysentery caused by #emph[Shigella] or bloody diarrhea caused by non-typhoidal #emph[Salmonella] in systemic infection. Antimicrobial therapy is contraindicated or controversial in STEC infection due to potential increased risk of HUS progression.

Travelers' diarrhea caused by ETEC typically responds well to three-day courses of fluoroquinolones or azithromycin. Giardiasis requires specific antimicrobial agents including metronidazole, tinidazole, or nitazoxanide.

== Antimotility Agents
<antimotility-agents>
Antimotility agents such as loperamide reduce stool frequency and improve patient comfort in some cases of noninflammatory diarrhea. However, their use should be avoided in inflammatory diarrhea (bloody diarrhea with fever) due to concerns about increasing the risk of toxic megacolon or complications. Use should also be avoided in diarrhea caused by organisms for which antimotility therapy may increase risk of complications (such as STEC).

== Nutritional Support
<nutritional-support>
Early reintroduction of appropriate nutrition supports recovery from diarrheal illness. Exclusive use of clear liquids for extended periods provides inadequate calories and may delay recovery. Age-appropriate solid foods can typically be reintroduced as tolerated, even during ongoing diarrhea. Lactose-containing foods may be poorly tolerated during acute diarrhea due to transient lactase deficiency resulting from epithelial damage.

== Zinc Supplementation
<zinc-supplementation>
Zinc supplementation (10-20 mg daily for 10-14 days) in children with acute diarrhea reduces the duration and severity of diarrhea #cite(<Lazzerini2016>, form: "prose") and reduces the risk of diarrhea recurrence in the following three months. The mechanism involves restoration of intestinal epithelial function and enhancement of immune responses. Zinc supplementation is particularly valuable in developing country settings where zinc deficiency is prevalent.

== Probiotics and Prebiotics
<probiotics-and-prebiotics>
The potential role of probiotics and prebiotics in preventing or treating acute diarrhea remains incompletely established. While some individual probiotic strains demonstrate benefit in specific contexts (such as #emph[Lactobacillus rhamnosus] in rotavirus gastroenteritis prevention), the evidence base is insufficient to recommend probiotics as general therapy for acute diarrhea. Similarly, prebiotics have not demonstrated consistent efficacy in treating acute diarrhea.

= Chronic Noninflammatory Diarrhea
<chronic-noninflammatory-diarrhea>
Persistent or chronic noninflammatory diarrhea lasting more than two weeks requires systematic evaluation to identify the underlying etiology, as different causes mandate different therapeutic approaches.

== Parasitic Causes
<parasitic-causes>
#emph[Giardia lamblia] and #emph[Cryptosporidium] species commonly cause chronic diarrhea, particularly in developing regions or in immunocompromised individuals. Diagnosis requires specific testing as noted previously, and antimicrobial therapy targets the specific organism.

== Tropical Sprue
<tropical-sprue>
Tropical sprue represents an idiopathic syndrome of chronic diarrhea and malabsorption occurring in endemic areas of South Asia and parts of the Caribbean. The etiology remains incompletely understood but likely involves chronic small intestinal bacterial overgrowth or contamination. The syndrome responds to long-term antimicrobial therapy with tetracyclines or fluoroquinolones.

== Small Intestinal Bacterial Overgrowth (SIBO)
<small-intestinal-bacterial-overgrowth-sibo>
Small intestinal bacterial overgrowth occurs when the proximal small intestine contains excessive numbers of bacteria (\>10^5 organisms per milliliter), exceeding the normal bacterial density. The condition results in chronic diarrhea, bloating, and malabsorption through bacterial deconjugation of bile salts, carbohydrate malabsorption, and epithelial damage.

Diagnosis of SIBO employs hydrogen and methane breath testing, which measures bacterial fermentation of oral lactulose or glucose. Treatment involves antimicrobial therapy targeting small intestinal bacteria, with rifaxomicin emerging as a preferred agent due to minimal systemic absorption and low resistance development.

== Brainerd Diarrhea
<brainerd-diarrhea>
Brainerd diarrhea represents an infectious, epidemic, acute-onset chronic diarrhea syndrome identified in multiple outbreaks in the United States and other countries. The disease causes persistent watery diarrhea lasting weeks to years. The etiology remains unidentified despite extensive investigation. The syndrome typically remits spontaneously over months to years without specific therapy.

= Noninfectious Mimics and Differential Diagnosis
<noninfectious-mimics-and-differential-diagnosis>
Several noninfectious conditions present with diarrhea that must be considered in the differential diagnosis of acute or chronic diarrheal disease.

== Medication-Associated Diarrhea
<medication-associated-diarrhea>
Numerous medications cause diarrhea through various mechanisms. Osmotically active agents such as polyethylene glycol solutions or sorbitol-containing products cause osmotic diarrhea. Prokinetic agents and antimicrobial drugs alter colonic motility and bacterial populations. Antimicrobial agents cause diarrhea through disruption of normal colonic flora and, in the case of some agents including clindamycin, through increased risk of #emph[Clostridioides difficile] infection.

== Endocrine Causes
<endocrine-causes>
Hyperthyroidism accelerates intestinal transit and causes diarrhea. Diabetes mellitus increases risk for diarrhea through multiple mechanisms including autonomic neuropathy affecting motility and predisposition to infections. Adrenal insufficiency can present with diarrhea and other constitutional symptoms.

== Inflammatory Bowel Disease
<inflammatory-bowel-disease>
Inflammatory bowel disease, including Crohn's disease and ulcerative colitis, presents with chronic diarrhea that may be clinically indistinguishable from infectious diarrhea. However, the chronicity, pattern of involvement, and demonstration of intestinal inflammation on endoscopy with histology help distinguish IBD from infectious causes.

== Irritable Bowel Syndrome
<irritable-bowel-syndrome>
Irritable bowel syndrome (IBS) causes chronic diarrhea in a large proportion of affected individuals. IBS is a functional disorder without demonstrable structural or inflammatory abnormalities and is diagnosed based on characteristic symptom patterns rather than on objective findings of inflammation or infection.

= Conclusion
<conclusion>
Infectious diarrhea represents a leading global cause of morbidity and mortality, particularly in children in developing regions. The vast epidemiologic diversity of etiologic pathogens---including viruses, bacteria, and protozoan parasites---requires a systematic diagnostic approach informed by clinical features, epidemiologic context, and host factors.

The distinction between inflammatory and noninflammatory diarrhea guides both diagnostic evaluation and empiric management decisions. While many cases of acute diarrhea resolve spontaneously with supportive care, some require specific antimicrobial therapy, and immunocompromised patients frequently require more intensive investigation and targeted interventions.

Advances in preventive strategies, including rotavirus vaccination and improved water and sanitation infrastructure, have reduced the burden of diarrheal disease in some regions. However, substantial challenges remain in reducing the global burden of infectious diarrhea, particularly in low- and middle-income countries where enteric infections continue to cause millions of deaths annually, predominantly in young children.

Future directions in management and prevention include development of improved oral vaccines against major enteric pathogens, enhancement of diagnostic capabilities through molecular methods, optimization of antimicrobial stewardship to combat emerging resistance, and expansion of access to clean water and sanitation infrastructure in resource-limited settings.

#horizontalrule

= References
<references>
#block[
] <refs>


 
  
#set bibliography(style: "diagnostic-microbiology-and-infectious-disease.csl") 


#bibliography("refs-diarrhea.bib")

