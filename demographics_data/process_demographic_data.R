library(tidyverse)
library(readr) 

# German demographic data
de_sex <- readxl::read_excel(here::here("demographics_data", "all_Leipzig_participants_nonames.xlsx")) |>
  rename(user_id = uid, sex = Gender) |>
  mutate(sex_demo = recode_values(sex, "m" ~ "Male", "f" ~ "Female"))

de_sex_cleaned <- de_sex |>
  transmute(user_id, sex = sex_demo)

# Colombian demographic data
co_sex <- readxl::read_excel(here::here("demographics_data", "infoUsuariosLevante_expanded.xlsx"))

co_sex_cleaned <- co_sex |>
  rename(user_id = `user_id 2025`) |>
  distinct(user_id, Sex) |>
  filter(!is.na(Sex)) |>
  transmute(
    user_id,
    sex = recode_values(Sex, "F" ~ "Female", "M" ~ "Male")
  )

# Combine all sources: demographic files take priority, survey fills gaps (incl. CA)
sex_data_cleaned <- bind_rows(de_sex_cleaned, co_sex_cleaned, survey_sex_cleaned) |>
  distinct(user_id, .keep_all = TRUE)
write_rds(sex_data_cleaned, here("data","sex_data_cleaned.rds"))