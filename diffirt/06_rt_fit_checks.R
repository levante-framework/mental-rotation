# Posterior predictive check of accuracy and response times for the fitted diffusion IRT models.
#   Rscript --vanilla diffirt/06_rt_fit_checks.R      (writes models/diffirt_rt_ppc.rds)
# For every observed person x item cell, simulate nrep responses from the fitted model, drawing the person's
# (gamma, theta) from the Laplace approximation to their posterior (factest with se = TRUE) so that shrinkage does not
# make the simulated data too homogeneous. Observed and simulated data get the same trimming (RT >= rt_min).
# Compared per item class and for correct and incorrect responses separately: accuracy, and the
# .1/.3/.5/.7/.9 RT quantiles. Models: Q (Ter shared by 2D/3D), Q (Ter per class), D (Ter shared by 2D/3D).
suppressMessages({library(dplyr); library(tidyr); library(readr); library(purrr); library(here)})
.libPaths(c(path.expand("~/Library/R/diffirt-fast"), .libPaths()))
suppressMessages({library(diffIRT); library(RWiener); library(parallel)})
RNGkind("L'Ecuyer-CMRG"); set.seed(2026)
nrep <- 10
probs <- c(.1, .3, .5, .7, .9)

m <- read_rds(here("data/diffirt_mats_rtmin0.5.rds"))
cls <- m$cols$item_uid; nit <- ncol(m$rt)
ij <- which(!is.na(m$rt), arr.ind = TRUE)               # (person, column) of every observed trial
obs <- tibble(person = ij[, 1], col = ij[, 2], item_uid = cls[ij[, 2]], rt = m$rt[ij], correct = m$x[ij])

models <- list(
  `Q, Ter by 2D/3D` = c("q_rtmin0.5_fast_nall_nq7-15_se_tergroup0.3.rds", "Q"),
  `Q, Ter per class` = c("q_rtmin0.5_fast_nall_nq7-15.rds", "Q"),
  `D, Ter by 2D/3D` = c("d_rtmin0.5_fast_nall_nq7-15_se_tergroup.rds", "D"))

qtab <- \(rt, correct, by) {
  tibble(rt = rt, correct = correct, by = by) |>
    summarise(n = n(), acc = NA_real_, q = list(quantile(rt, probs)), .by = c(by, correct)) |>
    unnest_wider(q, names_sep = "_") |> rename_with(\(z) sub("q_", "q", sub("%", "", z)), starts_with("q_"))
}

ppc_one <- function(name, file, model) {
  fit <- read_rds(here("models", paste0("diffirt_", file)))$fit
  sc <- factest(fit, se = TRUE)                           # gamma, se, theta, se
  p <- fit$par
  a <- p[1:nit]; v <- p[nit + 1:nit]; ter <- p[2 * nit + 1:nit]
  g_hat <- sc[, 1]; g_se <- sc[, 2] / sc[, 1]             # log-scale SD of gamma
  t_hat <- sc[, 3]; t_se <- sc[, 4]
  sim_rep <- function(r) {
    g <- exp(log(g_hat) + rnorm(nrow(sc), 0, g_se))
    th <- if (model == "Q") exp(log(t_hat) + rnorm(nrow(sc), 0, t_se / t_hat)) else t_hat + rnorm(nrow(sc), 0, t_se)
    A <- g[obs$person] / a[obs$col]
    nu <- if (model == "Q") th[obs$person] / v[obs$col] else th[obs$person] - v[obs$col]
    tau <- ter[obs$col]
    s <- vapply(seq_along(A), \(i) { o <- rwiener(1, A[i], tau[i], 0.5, nu[i]); c(o$q, o$resp == "upper") }, numeric(2))
    tibble(item_uid = obs$item_uid, rt = s[1, ], correct = s[2, ], rep = r)
  }
  sim <- bind_rows(mclapply(seq_len(nrep), sim_rep, mc.cores = 5)) |> filter(rt >= m$rt_min, rt < m$rt_max)
  per_rep <- sim |>
    summarise(n = n(), q = list(quantile(rt, probs)), .by = c(rep, item_uid, correct)) |>
    unnest_wider(q, names_sep = "") |> rename_with(\(z) sub("%", "", z), starts_with("q"))
  acc_rep <- sim |> summarise(acc = mean(correct), mean_rt = mean(rt), .by = c(rep, item_uid))
  list(name = name, quant = per_rep |> summarise(across(c(n, starts_with("q")), mean), .by = c(item_uid, correct)),
       acc = acc_rep |> summarise(across(c(acc, mean_rt), mean), .by = item_uid),
       acc_by = sim |> summarise(mean_rt = mean(rt), .by = c(item_uid, correct)) |> arrange(item_uid, correct))
}

obs_quant <- obs |> summarise(n = n(), q = list(quantile(rt, probs)), .by = c(item_uid, correct)) |>
  unnest_wider(q, names_sep = "") |> rename_with(\(z) sub("%", "", z), starts_with("q"))
obs_acc <- obs |> summarise(acc = mean(correct), mean_rt = mean(rt), .by = item_uid)
obs_by <- obs |> summarise(mean_rt = mean(rt), .by = c(item_uid, correct)) |> arrange(item_uid, correct)

res <- imap(models, \(x, nm) { cat("simulating:", nm, "\n"); ppc_one(nm, x[1], x[2]) })
out <- list(observed = list(quant = obs_quant, acc = obs_acc, by = obs_by), models = res, nrep = nrep)
write_rds(out, here("models/diffirt_rt_ppc.rds"), compress = "gz")

# --- summaries
qcols <- paste0("q", probs * 100)
cat("\nRMSE of RT quantiles (s), over item class x correct/incorrect cells (weighted by observed n):\n")
for (r in res) {
  j <- inner_join(obs_quant, r$quant, by = c("item_uid", "correct"), suffix = c("_o", "_s"))
  e <- sapply(qcols, \(q) sqrt(weighted.mean((j[[paste0(q, "_o")]] - j[[paste0(q, "_s")]])^2, j$n_o)))
  cat(sprintf("%-18s", r$name), paste(qcols, round(e, 2), collapse = "  "), "\n")
}
cat("\nAccuracy: mean abs error across classes:\n")
for (r in res) cat(sprintf("%-18s %.3f   mean-RT abs error %.2f s\n", r$name,
                           mean(abs(inner_join(obs_acc, r$acc, by = "item_uid", suffix = c("_o", "_s")) |> with(acc_o - acc_s))),
                           mean(abs(inner_join(obs_acc, r$acc, by = "item_uid", suffix = c("_o", "_s")) |> with(mean_rt_o - mean_rt_s)))))
cat("\nMean RT, errors minus correct (s): observed vs models\n")
dif <- \(b) b |> pivot_wider(names_from = correct, values_from = mean_rt, names_prefix = "c") |> mutate(diff = c0 - c1) |> select(item_uid, diff)
tab <- reduce(c(list(dif(obs_by) |> rename(observed = diff)), map(res, \(r) dif(r$acc_by) |> rename(!!r$name := diff))), left_join, by = "item_uid")
print(as.data.frame(tab |> mutate(across(where(is.numeric), \(z) round(z, 2)))))
