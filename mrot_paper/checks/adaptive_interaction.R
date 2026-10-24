source(here::here("mrot_paper/checks/prep.R"))
suppressMessages({library(lme4); library(marginaleffects)})
full_mod <- lmer(log_rt ~ angle_sc * stimulus * site_label * age_sc + trial_number * stimulus + adaptive * stimulus +
                   (1 + angle_sc | user_id), data = mrot_lme_data, REML = FALSE, control = lmerControl(optimizer = "bobyqa"))
print(as_tibble(slopes(full_mod, newdata = mrot_lme_data, re.form = NA, variables = "angle_sc", by = "adaptive", hypothesis = "b2 - b1 = 0")))
# full model + adaptive x angle interaction
m2 <- update(full_mod, . ~ . + angle_sc:adaptive)
print(anova(full_mod, m2))
print(coef(summary(m2))["angle_sc:adaptiveTRUE", ])
# simple model as in _00 but on this data
m3 <- lmer(log_rt ~ angle_sc * adaptive + (1 + angle_sc | user_id), data = mrot_lme_data, REML = FALSE, control = lmerControl(optimizer = "bobyqa"))
print(coef(summary(m3))["angle_sc:adaptiveTRUE", ])
# site-specific slopes by age group (young), for item 7
