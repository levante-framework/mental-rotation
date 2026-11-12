# Re-run the paper's age, sex and site analysis of ability with the diffusion IRT person scores.
#   Rscript --vanilla diffirt/05_diffirt_paper_analyses.R      (writes models/diffirt_paper_results.rds)
# Model as in the paper (_03_sex_diffs.qmd, sex-ability-mods): score ~ age * sex * site + (1 | user_id), sex sum-coded,
# effects as average marginal effects over the observed runs, expressed in SD units of the score.
# Scores compared: the paper's 2PL theta, the diffusion drift (log theta), the diffusion boundary scale (log gamma),
# and two descriptive run-level measures (accuracy, mean log RT) that anchor the interpretation.
suppressMessages({library(dplyr); library(tidyr); library(readr); library(purrr); library(here)})
source(here("mrot_paper/checks/prep.R"))   # mrot_df (paper's filtered runs, with 2PL theta), sex_data_cleaned
suppressMessages({library(lme4); library(marginaleffects)})

scores <- read_rds(here("models/diffirt_scores.rds")) |> select(run_id, gamma, theta)
trials <- read_rds(here("data/mrot_rt_trial.rds")) |>
  summarise(accuracy = mean(correct), mean_log_rt = mean(log(rt_s[rt_s > 0])), .by = run_id)

dat <- mrot_df |>
  rename(theta_2pl = metric_value) |>
  inner_join(scores, by = "run_id") |>
  inner_join(trials, by = "run_id") |>
  inner_join(sex_data_cleaned, by = "user_id") |>
  filter(!is.na(sex)) |>
  mutate(sex = factor(sex), site_label = factor(site_label),
         log_theta = log(theta), log_gamma = log(gamma))
contrasts(dat$sex) <- contr.sum(levels(dat$sex))
cat("runs:", nrow(dat), " users:", n_distinct(dat$user_id), "\n")

measures <- c(`2PL theta` = "theta_2pl", `Diffusion log theta (drift)` = "log_theta",
              `Diffusion log gamma (boundary)` = "log_gamma", `Accuracy` = "accuracy", `Mean log RT` = "mean_log_rt")

one <- function(y, label) {
  d <- dat; sdy <- sd(d[[y]])
  d$y <- d[[y]]
  m <- lmer(y ~ age * sex * site_label + (1 | user_id), data = d)
  d$task <- "mrot"
  tidy <- \(x, what, label = NULL) {
    x <- as_tibble(x)
    tibble(measure = label_, effect = if (is.null(label)) what else paste(what, x[[label]]),
           estimate_sd = x$estimate / sdy, se_sd = x$std.error / sdy, p = x$p.value)
  }
  label_ <- label
  age <- avg_slopes(m, variables = "age", newdata = d, re.form = NA) |> tidy("age (per year)")
  sex <- avg_comparisons(m, variables = list(sex = "pairwise"), newdata = d, re.form = NA) |> tidy("sex (Male - Female)")
  agesex <- slopes(m, variables = "age", newdata = d, re.form = NA, by = "sex", hypothesis = difference ~ pairwise) |>
    tidy("age slope: Male - Female")
  site <- avg_comparisons(m, variables = list(site_label = "pairwise"), newdata = d, re.form = NA) |>
    tidy("site:", "contrast")
  sex_site <- comparisons(m, variables = list(sex = "pairwise"), newdata = d, re.form = NA, by = "site_label") |>
    tidy("sex within", "site_label")
  r2 <- performance::model_performance(m)
  list(effects = bind_rows(age, sex, agesex, sex_site, site),
       fit = tibble(measure = label, R2_conditional = r2$R2_conditional, R2_marginal = r2$R2_marginal))
}
res <- imap(measures, \(y, label) one(y, label))
effects <- map_dfr(res, "effects"); fits <- map_dfr(res, "fit")
write_rds(list(effects = effects, fits = fits, data = dat), here("models/diffirt_paper_results.rds"))

main <- effects |> filter(effect %in% c("age (per year)", "sex (Male - Female)", "age slope: Male - Female")) |>
  mutate(txt = sprintf("%.3f (%.3f), p=%.3f", estimate_sd, se_sd, p)) |>
  select(measure, effect, txt) |> pivot_wider(names_from = effect, values_from = txt)
print(as.data.frame(main), right = FALSE)
cat("\nsex within site (SD units):\n")
print(effects |> filter(startsWith(effect, "sex within")) |>
        mutate(txt = sprintf("%.2f (%.2f)", estimate_sd, se_sd)) |> select(measure, effect, txt) |>
        pivot_wider(names_from = effect, values_from = txt) |> as.data.frame(), right = FALSE)
cat("\nsite contrasts (SD units):\n")
print(effects |> filter(startsWith(effect, "site:")) |>
        mutate(txt = sprintf("%.2f (%.2f)", estimate_sd, se_sd)) |> select(measure, effect, txt) |>
        pivot_wider(names_from = measure, values_from = txt) |> as.data.frame(), right = FALSE)
cat("\nR2:\n"); print(as.data.frame(fits |> mutate(across(where(is.numeric), \(z) round(z, 3)))))
