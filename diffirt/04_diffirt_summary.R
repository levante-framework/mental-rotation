# Item-class parameters with standard errors, and person scores, from the preferred diffusion IRT fit
# (rt_min 0.5 s, Ter shared by 2D/3D and started at 0.3 s, nq = 7, 15, se = TRUE).
suppressMessages({library(dplyr); library(readr); library(here)})
.libPaths(c(path.expand("~/Library/R/diffirt-fast"), .libPaths()))
suppressMessages(library(diffIRT))
r <- read_rds(here("models/diffirt_q_rtmin0.5_fast_nall_nq7-15_se_tergroup0.3.rds")); f <- r$fit
m <- read_rds(here("data/diffirt_mats_rtmin0.5.rds"))
cls <- m$cols$item_uid; nit <- length(cls); k <- as.integer(factor(cls)); first <- match(1:max(k), k)
tab <- tibble(class = levels(factor(cls)),
              a = f$par[first], a_se = f$std.err[first],
              v = f$par[nit + first], v_se = f$std.err[nit + first],
              ter = f$par[2 * nit + first], ter_se = f$std.err[2 * nit + first])
print(as.data.frame(mutate(tab, across(where(is.numeric), \(x) round(x, 3)))))
cat("omega_gamma, omega_theta:", round(tail(f$par, 2), 3), " (SE", round(tail(f$std.err, 2), 3), ")\n")
cat("-2LL", round(f$totLL, 1), " npars", f$npars, " AIC", round(f$AIC, 1), " BIC", round(f$BIC, 1), "\n")
write_rds(tab, here("models/diffirt_item_params.rds"))

sc <- factest(f)
scores <- bind_cols(m$runs, tibble(gamma = sc[, 1], theta = sc[, 2])) |>
  left_join(read_rds(here("models/mrot_scores.rds")) |> filter(model_set == "multigroup_dataset") |>
              select(run_id, theta_irt = metric_value), by = "run_id")
write_rds(scores, here("models/diffirt_scores.rds"), compress = "gz")
cat("\nSpearman correlations:\n")
print(round(cor(scores[c("gamma", "theta", "theta_irt", "age")], use = "pairwise", method = "spearman"), 2))
