library(readr)
library(dplyr)

# from https://github.com/levante-framework/survey-caregiver
survey_data_caregiver <- read_rds("data/survey_data_caregiver.rds")

survey_gender_conditions <- survey_data_caregiver |>
  arrange(variable_order) |>
  filter(form_subconstruct %in% c("Sex and Gender", "Cognition and Learning") |
           str_detect(variable, "Hearing|Eyesight|Vision")) |>
  filter_out(str_detect(variable, "Exp$")) |>
  select(site, dataset, survey_id, respondent_id, child_id, form_subconstruct,
         variable, value, contains("response"))

write_rds(survey_gender_conditions, "survey_gender_conditions.rds",
          compress = "gz")
