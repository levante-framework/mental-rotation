# Checks of claims added to the manuscript after the review: boys' accuracy, and additive-scale
# slopes / rotation rates by age group and stimulus type.
source(here::here("mrot_paper/checks/prep.R"))
suppressMessages({library(lme4); library(marginaleffects)})
deg <- 40; yrs <- 2
cat("\n== accuracy by sex ==\n")
acc <- mrot_rt_trial |> filter(trial_number != 1) |>
  inner_join(sex_data_cleaned, by = "user_id") |> filter(!is.na(sex)) |>
  mutate(item_group = factor(item_group), site_label = factor(site_label), sex = factor(sex),
         adaptive = factor(adaptive), correct = as.integer(correct),
         angle_sc = (angle - mean(angle)) / deg, age_sc = (age - mean(age)) / yrs)
contrasts(acc$sex) <- contr.sum(levels(acc$sex)); contrasts(acc$site_label) <- contr.sum(levels(acc$site_label))
contrasts(acc$item_group) <- contr.sum(levels(acc$item_group))
g <- glmer(correct ~ angle_sc * item_group + site_label + age_sc + adaptive + sex + (1 | user_id), acc,
           family = binomial, nAGQ = 0)
print(round(summary(g)$coefficients["sex1", ], 3))
cat("observed accuracy by sex:\n"); print(acc |> summarise(acc = round(mean(correct), 3), n = n(), .by = c(sex, item_group)))
cat("sex AME on P(correct):\n"); print(as_tibble(avg_comparisons(g, newdata = acc, variables = "sex", re.form = NA)) |> select(contrast, estimate, std.error, p.value, conf.low, conf.high))
cat("\n== additive slopes (s per 40 deg) by age group and stimulus ==\n")
d <- mrot_lme_data |> mutate(age_group = cut(age, c(5, 8, 11, 14), right = FALSE))
m <- lmer(rt_s ~ angle_sc * item_group * age_group + site_label + (1 + angle_sc | user_id), d, REML = FALSE,
          control = lmerControl(optimizer = "bobyqa"))
sl <- slopes(m, newdata = d, re.form = NA, variables = "angle_sc", by = c("item_group", "age_group")) |> as_tibble()
print(sl |> transmute(item_group, age_group, s_per_40 = round(estimate, 3), se = round(std.error, 3), deg_per_s = round(40 / estimate)))
sl2 <- slopes(m, newdata = d, re.form = NA, variables = "angle_sc", by = c("item_group")) |> as_tibble()
print(sl2 |> transmute(item_group, s_per_40 = round(estimate, 3), deg_per_s = round(40 / estimate)))
cat("mean RT (s) by age group:\n"); print(d |> summarise(m = round(mean(rt_s), 2), .by = age_group) |> arrange(age_group))
