# Person scores and fit checks for the fitted diffusion IRT model.
#   Rscript --vanilla diffirt/03_diffirt_checks.R [model file in models/]
suppressMessages({library(dplyr); library(readr); library(here)})
.libPaths(c(path.expand("~/Library/R/diffirt-fast"), .libPaths()))
suppressMessages(library(diffIRT))
f <- commandArgs(TRUE)[1]; if (is.na(f)) f <- "diffirt_q_fast_nall_nq7-15-25.rds"
r <- read_rds(here("models", f)); fit <- r$fit
m <- read_rds(here("data/diffirt_mats.rds"))

t <- system.time(sc <- factest(fit))
cat("factest elapsed (s):", round(t[["elapsed"]], 2), "\n"); print(head(sc, 3)); print(dim(sc))
scores <- bind_cols(m$runs, as_tibble(sc, .name_repair = "minimal") |> setNames(paste0("fs_", seq_len(ncol(sc)))))
irt <- read_rds(here("models/mrot_scores.rds")) |>
  filter(model_set == "multigroup_dataset") |> select(run_id, theta_irt = metric_value)
scores <- left_join(scores, irt, by = "run_id")
write_rds(scores, here("models/diffirt_scores.rds"), compress = "gz")

cat("\ncorrelations among scores, age and the paper's IRT theta:\n")
nm <- names(scores)[startsWith(names(scores), "fs_")]
print(round(cor(scores[c(nm, "theta_irt", "age")], use = "pairwise", method = "spearman"), 2))
cat("\nmean scores by dataset:\n")
print(scores |> summarise(across(c(all_of(nm), theta_irt), \(x) round(mean(x, na.rm = TRUE), 2)), n = n(), .by = dataset))
