library(tidyverse)
library(jsonlite)

# ---------------------------------------------------------------------------
# Load source data and sample
# ---------------------------------------------------------------------------
load("Shiny_app/ed_sample.rdata")
set.seed(2026)
ed <- df[sample(nrow(df), 5500), ]

# ---------------------------------------------------------------------------
# Chief-complaint mappings (top 30)
# ---------------------------------------------------------------------------
cc_map <- c(
  cc_abdominalpain                       = "Vatsakipu",
  cc_other                               = "Muu syy",
  cc_chestpain                           = "Rintakipu",
  cc_shortnessofbreath                   = "Hengenahdistus",
  cc_backpain                            = "Selkäkipu",
  cc_fall                                = "Kaatuminen",
  cc_alcoholintoxication                 = "Alkoholipäihtymys",
  cc_motorvehiclecrash                   = "Liikenneonnettomuus",
  cc_dizziness                           = "Huimaus",
  cc_cough                               = "Yskä",
  cc_emesis                              = "Oksentelu",
  cc_legpain                             = "Jalkakipu",
  `cc_headache-newonsetornewsymptoms`    = "Päänsärky",
  cc_flankpain                           = "Kylkikipu",
  cc_suicidal                            = "Itsetuhoisuus",
  cc_alteredmentalstatus                 = "Tajunnantason muutos",
  `cc_fall>65`                           = "Kaatuminen >65v",
  cc_weakness                            = "Heikkous",
  cc_sorethroat                          = "Kurkkukipu",
  cc_kneepain                            = "Polvikipu",
  cc_psychiatricevaluation               = "Psykiatrinen arvio",
  `cc_fever-9weeksto74years`             = "Kuume",
  cc_rash                                = "Ihottuma",
  cc_medicalproblem                      = "Yleinen ongelma",
  cc_nausea                              = "Pahoinvointi",
  cc_syncope                             = "Pyörtyminen",
  cc_footpain                            = "Jalkateräkipu",
  cc_dentalpain                          = "Hammassärky",
  cc_legswelling                         = "Jalan turvotus",
  cc_shoulderpain                        = "Olkapääkipu"
)

# ---------------------------------------------------------------------------
# Medication mappings (top 20)
# ---------------------------------------------------------------------------
meds_map <- c(
  meds_cardiovascular        = "Sydän/verisuoni",
  meds_analgesics            = "Kipulääke",
  meds_gastrointestinal      = "Ruoansulatus",
  meds_psychotherapeuticdrugs = "Psyykelääke",
  meds_vitamins              = "Vitamiini",
  meds_cnsdrugs              = "Keskushermosto",
  meds_antibiotics           = "Antibiootti",
  meds_hormones              = "Hormoni",
  `meds_elect/caloric/h2o`   = "Elektrolyytti",
  meds_antihyperglycemics    = "Diabeteslääke",
  meds_diuretics             = "Nesteenpoisto",
  meds_skinpreps             = "Iholääke",
  meds_antiplateletdrugs     = "Verihiutale-estäjä",
  meds_antiasthmatics        = "Astmalääke",
  `meds_sedative/hypnotics`  = "Uni/rauhoittava",
  meds_thyroidpreps          = "Kilpirauhaslääke",
  meds_autonomicdrugs        = "Autonominen herm.",
  meds_eentpreps             = "Silmä/korva/nenä",
  meds_anticoagulants        = "Verenohennuslääke",
  meds_antiarthritics        = "Nivellääke"
)

# ---------------------------------------------------------------------------
# Helper: sanitise Finnish name → safe column-name fragment
#   lowercase, strip everything that is not a-z
# ---------------------------------------------------------------------------
sanitize <- function(x) gsub("[^a-z]", "", tolower(x))

# ---------------------------------------------------------------------------
# Build export dataframe
# ---------------------------------------------------------------------------
out <- ed |>
  transmute(
    # === Outcome ===
    dispo = ifelse(disposition == "Admit", "Osastolle", "Kotiutunut"),

    # === Demographics ===
    ika = as.integer(age),

    sukupuoli = ifelse(gender == "Female", "Nainen", "Mies"),

    siviilisaaty = case_match(
      as.character(maritalstatus),
      "Single"               ~ "Naimaton",
      "Married/Life Partner" ~ "Naimisissa",
      "Divorced"             ~ "Eronnut",
      "Widowed"              ~ "Leski",
      .default                = "Muu/Tuntematon"
    ),

    tyollisyys = case_match(
      as.character(employstatus),
      "Not Employed"         ~ "Työtön",
      "Full Time"            ~ "Kokopäivätyö",
      "Retired"              ~ "Eläkeläinen",
      "Disabled"             ~ "Työkyvytön",
      "Part Time"            ~ "Osa-aikatyö",
      "Student - Full Time"  ~ "Opiskelija",
      "Student - Part Time"  ~ "Opiskelija",
      "Self Employed"        ~ "Yrittäjä",
      .default                = "Muu/Tuntematon"
    ),

    # === Visit info ===
    esi = as.integer(as.character(esi)),

    saapumistapa = case_match(
      as.character(arrivalmode),
      "ambulance"             ~ "Ambulanssi",
      "Car"                   ~ "Auto",
      "Walk-in"               ~ "Kävellen",
      "Police"                ~ "Poliisi",
      "Public Transportation" ~ "Julkinen liikenne",
      .default                 = "Muu"
    ),

    viikonpaiva = case_match(
      as.character(arrivalday),
      "Monday"    ~ "Ma",
      "Tuesday"   ~ "Ti",
      "Wednesday" ~ "Ke",
      "Thursday"  ~ "To",
      "Friday"    ~ "Pe",
      "Saturday"  ~ "La",
      "Sunday"    ~ "Su"
    ),

    kellonaika = as.character(arrivalhour_bin),

    kuukausi = case_match(
      as.character(arrivalmonth),
      "January"   ~ "Tammi",
      "February"  ~ "Helmi",
      "March"     ~ "Maalis",
      "April"     ~ "Huhti",
      "May"       ~ "Touko",
      "June"      ~ "Kesä",
      "July"      ~ "Heinä",
      "August"    ~ "Elo",
      "September" ~ "Syys",
      "October"   ~ "Loka",
      "November"  ~ "Marras",
      "December"  ~ "Joulu"
    ),

    # === History ===
    aiemmat_kaynti      = as.integer(n_edvisits),
    aiemmat_osasto      = as.integer(n_admissions),

    edellinen_lopputulos = case_match(
      as.character(previousdispo),
      "Admit"            ~ "Osastolle",
      "Discharge"        ~ "Kotiutunut",
      "AMA"              ~ "Omalla vastuulla",
      "Eloped"           ~ "Poistunut",
      "No previous dispo" ~ "Ei aiempia",
      .default             = "Muu"
    ),

    # === Triage vitals (6) ===
    tr_syke    = as.integer(round(triage_vital_hr)),
    tr_sys     = as.integer(round(triage_vital_sbp)),
    tr_dia     = as.integer(round(triage_vital_dbp)),
    tr_hengitys = as.integer(round(triage_vital_rr)),
    tr_spo2    = as.integer(round(triage_vital_o2)),
    tr_lampo   = round((triage_vital_temp - 32) * 5 / 9, 1),

    # === Last vitals (6) ===
    vi_syke    = as.integer(round(pulse_last)),
    vi_sys     = as.integer(round(sbp_last)),
    vi_dia     = as.integer(round(dbp_last)),
    vi_hengitys = as.integer(round(resp_last)),
    vi_spo2    = as.integer(round(spo2_last)),
    vi_lampo   = round((temp_last - 32) * 5 / 9, 1),

    # === Labs (13) — converted to SI / Finnish units ===
    lab_valkos = round(wbc_last, 1),
    lab_hb     = as.integer(round(hemoglobin_last * 10)),
    lab_hkr    = round(hematocrit_last, 1),
    lab_trom   = round(platelets_last, 0),
    lab_gluk   = round(glucose_last * 0.0555, 1),
    lab_krea   = as.integer(round(creatinine_last * 88.4)),
    lab_urea   = round(bun_last * 0.357, 1),
    lab_na     = as.integer(round(sodium_last)),
    lab_k      = round(potassium_last, 1),
    lab_cl     = as.integer(round(chloride_last)),
    lab_lakt   = round(`lactate,poc_last`, 1),
    lab_tnt    = round(troponint_last, 1),
    lab_ck     = as.integer(round(cktotal_last)),

    # === Imaging (9) — counts ===
    kuv_thorax  = cxr_count,
    kuv_ekg     = ekg_count,
    kuv_paa_tt  = headct_count,
    kuv_muu_tt  = otherct_count,
    kuv_echo    = echo_count,
    kuv_muu_uu  = otherus_count,
    kuv_muu_rtg = otherxr_count,
    kuv_mri     = mri_count,
    kuv_muu     = otherimg_count
  )

# ---------------------------------------------------------------------------
# fct_lump_n for siviilisaaty and tyollisyys
# ---------------------------------------------------------------------------
out <- out |>
  mutate(
    siviilisaaty = fct_lump_n(factor(siviilisaaty), n = 4, other_level = "Muu/Tuntematon"),
    tyollisyys   = fct_lump_n(factor(tyollisyys),   n = 7, other_level = "Muu/Tuntematon")
  )

# ---------------------------------------------------------------------------
# Chief complaints (top 30) — binary 0/1
# ---------------------------------------------------------------------------
for (src in names(cc_map)) {
  fi    <- cc_map[[src]]
  col   <- paste0("ts_", sanitize(fi))
  out[[col]] <- as.integer(ed[[src]])
}

# ---------------------------------------------------------------------------
# Medications (top 20) — binary 0/1 (has medication > 0)
# ---------------------------------------------------------------------------
for (src in names(meds_map)) {
  fi    <- meds_map[[src]]
  col   <- paste0("laake_", sanitize(fi))
  out[[col]] <- as.integer(ed[[src]] > 0)
}

# ---------------------------------------------------------------------------
# Write JSON
# ---------------------------------------------------------------------------
json <- toJSON(out, dataframe = "rows", na = "null", digits = 3, auto_unbox = TRUE)
writeLines(json, "ed_data.json")

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
cat("Rows:", nrow(out), "\n")
cat("Columns:", ncol(out), "\n")
cat("File size:", round(file.size("ed_data.json") / 1024, 0), "KB\n")
cat("\nColumn names:\n")
cat(paste(names(out), collapse = ", "), "\n")
