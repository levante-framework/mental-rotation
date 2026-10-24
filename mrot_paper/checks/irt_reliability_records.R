# Recompute the marginal reliabilities reported in the paper from the saved model records
# (needs the rlevante package source: set RLEVANTE_PATH, default ../rlevante; run from the repo root)
suppressMessages({library(mirt); library(dplyr); library(purrr); library(tibble)
  pkgload::load_all(Sys.getenv("RLEVANTE_PATH", "../rlevante"), quiet = TRUE)})
rebuild <- function(path) {
  rec <- readRDS(path)
  m <- multipleGroup(rec@data, group = rec@groups, pars = rec@model_vals, TOL = NaN)
  list(rec = rec, mod = m)
}
for (subset in c("all_items", "overlap_items")) for (it in c("2pl", "rasch")) {
  f <- file.path("models/mrot/multigroup_dataset", subset, sprintf("mrot_%s_f1_scalar.rds", it))
  if (!file.exists(f)) next
  r <- rebuild(f); m <- r$mod
  cat("\n==", subset, it, " items:", ncol(r$rec@data), " runs:", nrow(r$rec@data),
      " nestpars:", extract.mirt(m, "nestpars"), " logLik:", round(m@Fit$logLik, 1), " BIC:", round(m@Fit$BIC, 1), "\n")
  for (g in m@Data$groupNames) {
    mg <- extract.group(m, g); cf <- coef(mg, simplify = TRUE)
    cat(sprintf("  %-26s rxx = %.3f  var = %.2f  mean = %.2f  mean a1 = %.2f\n", g, marginal_rxx(mg),
                cf$cov[1], cf$means[1], mean(cf$items[, "a1"])))
  }
}

# ---- alternative reliability definitions on the same group models -----------------------------
# mirt::marginal_rxx integrates TI / (TI + var_theta) against a standard normal density, whatever the
# fitted group mean and variance. With a group variance of v, reliability is v*TI / (v*TI + 1), and the
# trait is distributed N(mean, v). Also report the empirical reliability from EAP scores.
rxx_alt <- function(mg) {
  cf <- coef(mg, simplify = TRUE); mu <- cf$means[1]; v <- cf$cov[1]
  fn <- function(th) { ti <- testinfo(mg, matrix(th)); v * ti / (v * ti + 1) * dnorm(th, mu, sqrt(v)) }
  integrate(fn, mu - 8 * sqrt(v), mu + 8 * sqrt(v))$value
}
res <- list()
for (subset in c("all_items", "overlap_items")) for (it in c("2pl", "rasch")) {
  f <- file.path("models/mrot/multigroup_dataset", subset, sprintf("mrot_%s_f1_scalar.rds", it))
  if (!file.exists(f)) next
  m <- rebuild(f)$mod
  for (g in m@Data$groupNames) {
    mg <- extract.group(m, g); fs <- fscores(mg, method = "EAP", full.scores.SE = TRUE)
    res[[length(res) + 1]] <- tibble(subset, itemtype = it, group = g,
      rxx_mirt = marginal_rxx(mg), rxx_density_corrected = rxx_alt(mg),
      rxx_empirical = empirical_rxx(fs), var_theta = coef(mg, simplify = TRUE)$cov[1])
  }
}
res <- bind_rows(res); print(as.data.frame(res), digits = 3)
saveRDS(res, "models/mrot_rxx_check.rds")
