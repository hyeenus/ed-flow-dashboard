# FinnEM Akatemia 2026 — Quarto RevealJS Esitys

## Tarkoitus
Interaktiivinen Quarto RevealJS -esitys kvantitatiivisen tutkimuksen opettamiseen FinnEM Akatemia 2026 workshopissa. Kohderyhmä: YAMK/AMK-sairaanhoitajat, ensihoitajat ja nuoret lääketieteen väitöskirjatutkijat.

## Tiedostot
- `20260413_FinnEM_Akatemia_Workshop_esitys_2026.qmd` — pääesitys
- `slides-custom.css` — kompaktit OJS-kontrollit, responsiivinen asettelu
- `Shiny_app/ed_sample.rdata` — lähdedata (11 210 päivystyskäyntiä, 972 saraketta)

## Tekninen toteutus
- **Quarto 1.8.27** + RevealJS + OJS (Observable JavaScript)
- R setup-lohko lataa `ed_sample.rdata`, ottaa 800 rivin satunnaisotoksen (`set.seed(2026)`) ja vie muuttujat OJS:ään `ojs_define()`-funktiolla
- Kaikki kuvaajat piirretään OJS:ssä: Observable Plot + raaka D3.js SVG
- Ei palvelinriippuvuuksia — toimii staattisena HTML:nä (paitsi OJS vaatii http-palvelimen, ei file://)

## Interaktiiviset diat
1. **Pylväskuvaaja** — Saapumistapa (aidosti kategorinen). Lukumäärä/prosentti-toggle.
2. **Pinottu pylväs** — ESI × jatkotoimenpide. Lukumäärä/prosentti.
3. **Boxplot-opetus** — 60 ihmisfiguuria pituusjärjestyksessä, 5-vaiheinen rakentuminen:
   - ① Järjestys → ② Mediaani (30. hlö = 170 cm) → ③ Kvartiilit (Q1=164, Q3=176)
   - → ④ Viikset (150–194 cm) → ⑤ Outlierit (140, 143, 197, 204 cm)
   - Boxplot piirtyy figuurien alle linjattuna niiden x-positioihin
4. **Boxplot-vertailu** — Osastohoito vs. kotiutus, select-valitsimella (ikä/syke/RR/heng.taaj.)
   - D3 SVG boxplotit: viikset EIVÄT mene laatikon läpi
5. **Histogrammi** — Ikäjakauma, bin-slideri (5–50), kuvateksti
6. **Scatter** — Ikä × syst. RR, väritys (ESI/sydänlääkitys), regressiosuora ryhmäväreillä
7. **Jatkotoimenpide** — Pinottu pylväs, ryhmittely: ESI/saapumistapa/sukupuoli/viikonpäivä
8. **Ristiintaulukointi** — Ambulanssi vs. kävellen × jatkotoimenpide, click-to-reveal p-arvo

## Datan muuttujat (OJS:ään viedyt)
| R-nimi | Suomeksi | Tyyppi |
|--------|----------|--------|
| ika | Ikä | Jatkuva (18–107) |
| sukupuoli | Nainen/Mies | Kategorinen |
| jatkotoimenpide | Osastohoito/Kotiutus | Binääri |
| esi | ESI-luokka | Ordinaali (1–5) |
| saapumistapa | Ambulanssi/Auto/Kävellen/Muu | Kategorinen |
| viikonpaiva | Ma–Su | Kategorinen |
| syke | Syke (bpm) | Jatkuva |
| systolinen | Syst. verenpaine (mmHg) | Jatkuva |
| hengitystaajuus | Heng.taajuus (/min) | Jatkuva |
| lampo | Lämpötila (°C, muunnettu F→C) | Jatkuva |
| spo2 | SpO2 (%) | Jatkuva |
| sydanlaake | Sydänlääkitys (0/1) | Binääri |
| aiemmat_kaynti | Aiemmat päivystyskäynnit | Jatkuva |

## Tunnetut rajoitukset / jatkokehitys
- OJS-kuvaajat eivät toimi `file://`-protokollalla — vaatii http-palvelimen tai Quarto Pubin
- `embed-resources: true` ei ole testattu OJS-soluilla
- Multiplex (diojen synkronointi yleisölle) ei ole käytössä — QR-koodi riittää
- Boxplot-vertailun outlier-pisteet voisivat näyttää tooltipissa tarkan arvon
- Chi-square p-arvo on kovakoodattu R:ssä — muuttuu jos seed/otos muuttuu
- Esitys linkittää ed_flow Shiny-dashboardiin (anssis.shinyapps.io/ed_flow/) harjoituksia varten

## Liittyvät projektit
- `interaktiiviset.html` — erillinen standalone D3.js-harjoitussovellus (8 demoa)
- `Shiny_app/app.R` — ed_flow Shiny-dashboard (tämän optimointi seuraava tehtävä)
