# Does the response time add information beyond accuracy?
#   Rscript --vanilla diffirt/07_rt_information.R      (writes models/diffirt_rt_information.rds)
# 1. Split-half: split each run's trials at random into two halves, score each half with (i) the paper's 2PL
#    (item parameters fixed at the scalar all_items values, N(0,1) prior, EAP) and (ii) the Q-diffusion model
#    (item parameters fixed at the full-data fit, factest), and compare split-half reliability and cross-half prediction.
#    Persons need >= 16 trials. The same trials feed both models; only the diffusion model sees the RTs.
# 2. Test-retest: children with two runs >= 3 months apart; stability and cross-prediction of the full-run scores.
suppressMessages({library(dplyr); library(tidyr); library(readr); library(purrr); library(here)})
.libPaths(c(path.expand("~/Library/R/diffirt-fast"), .libPaths()))
suppressMessages(library(diffIRT))
set.seed(11)
nsplit <- 20; min_trials <- 16

m <- read_rds(here("data/diffirt_mats_rtmin0.5.rds"))
fit <- read_rds(here("models/diffirt_q_rtmin0.5_fast_nall_nq7-15_se_tergroup0.3.rds"))$fit
cls <- m$cols$item_uid
irt <- read_rds(here("models/mrot_coef.rds")) |>
  filter(model_set == "multigroup_dataset", subset == "all_items", itemtype == "2pl", invariance == "scalar") |>
  distinct(item_uid = item, a1, d, g)
par2 <- irt[match(cls, irt$item_uid), ]                  # 2PL parameters of each column
grid <- seq(-6, 6, by = .05); prior <- dnorm(grid)

score_2pl <- function(x) {                              # EAP under the fixed 2PL with guessing, N(0,1) prior
  vapply(seq_len(nrow(x)), \(i) {
    j <- which(!is.na(x[i, ]))
    p <- par2$g[j] + (1 - par2$g[j]) * plogis(outer(grid, par2$a1[j]) + rep(par2$d[j], each = length(grid)))
    xm <- matrix(rep(x[i, j], each = length(grid)), length(grid))
    ll <- rowSums(xm * log(p) + (1 - xm) * log(1 - p))
    w <- exp(ll - max(ll)) * prior; sum(grid * w) / sum(w)
  }, numeric(1))
}
score_q <- function(rt, x) {                            # factest on new data, item parameters from the full fit
  f <- fit; f$rt <- rt; f$score <- x; f$N <- nrow(rt)
  s <- factest(f); cbind(log_theta = log(s[, 2]), log_gamma = log(s[, 1]))
}

keep <- which(rowSums(!is.na(m$rt)) >= min_trials)
rt <- m$rt[keep, ]; x <- m$x[keep, ]
cat("persons with >=", min_trials, "trials:", length(keep), "of", nrow(m$rt), "\n")

one_split <- function(s) {
  # random half per trial, balanced within person by ranking random numbers
  u <- matrix(runif(length(rt)), nrow(rt)); u[is.na(rt)] <- NA
  r <- t(apply(u, 1, rank, na.last = "keep"))
  h <- r <= ceiling(rowSums(!is.na(rt)) / 2)[row(r)]; h[is.na(h)] <- FALSE
  mk <- \(sel) { rr <- rt; xx <- x; rr[!sel | is.na(rt)] <- NA; xx[!sel | is.na(x)] <- NA; list(rt = rr, x = xx) }
  a <- mk(h); b <- mk(!h)
  sc <- \(z) { q <- score_q(z$rt, z$x); tibble(irt = score_2pl(z$x), q_theta = q[, 1], q_gamma = q[, 2],
                                                 acc = rowMeans(z$x, na.rm = TRUE), mlrt = rowMeans(log(z$rt), na.rm = TRUE)) }
  A <- sc(a); B <- sc(b)
  list(A = A, B = B)
}
splits <- map(seq_len(nsplit), \(s) { cat("split", s, "\n"); one_split(s) })

scores <- c("irt", "q_theta", "q_gamma", "acc", "mlrt")
rel <- map_dfr(splits, \(sp) tibble(score = scores, r = map_dbl(scores, \(v) cor(sp$A[[v]], sp$B[[v]])))) |>
  summarise(r_half = mean(r), sd_over_splits = sd(r), .by = score) |>
  mutate(spearman_brown = 2 * r_half / (1 + r_half))

# cross-half prediction: criterion from half B, predictors from half A (and the reverse), partial R2 added by the other score
cross <- map_dfr(splits, \(sp) {
  d <- bind_rows(mutate(bind_cols(sp$A |> rename_with(\(z) paste0(z, "_1")), sp$B |> rename_with(\(z) paste0(z, "_2"))), dir = 1),
                 mutate(bind_cols(sp$B |> rename_with(\(z) paste0(z, "_1")), sp$A |> rename_with(\(z) paste0(z, "_2"))), dir = 2))
  tibble(
    r_irt1_irt2 = cor(d$irt_1, d$irt_2), r_qth1_irt2 = cor(d$q_theta_1, d$irt_2),
    r_qth1_qth2 = cor(d$q_theta_1, d$q_theta_2), r_irt1_qth2 = cor(d$irt_1, d$q_theta_2),
    # criterion = accuracy in half 2 (owned by neither model's scale)
    r_irt1_acc2 = cor(d$irt_1, d$acc_2), r_qth1_acc2 = cor(d$q_theta_1, d$acc_2),
    r2_acc2_irt = summary(lm(acc_2 ~ irt_1, d))$r.squared,
    r2_acc2_irt_q = summary(lm(acc_2 ~ irt_1 + q_theta_1 + q_gamma_1, d))$r.squared,
    r2_irt2_irt = summary(lm(irt_2 ~ irt_1, d))$r.squared,
    r2_irt2_irt_q = summary(lm(irt_2 ~ irt_1 + q_theta_1 + q_gamma_1, d))$r.squared,
    r2_irt2_irt_rt = summary(lm(irt_2 ~ irt_1 + mlrt_1, d))$r.squared,
    r2_qth2_qth = summary(lm(q_theta_2 ~ q_theta_1, d))$r.squared,
    r2_qth2_qth_irt = summary(lm(q_theta_2 ~ q_theta_1 + irt_1, d))$r.squared)
}) |> summarise(across(everything(), mean))

# --- test-retest
sc <- read_rds(here("models/diffirt_scores.rds")) |> mutate(log_theta = log(theta), log_gamma = log(gamma))
pairs <- sc |> arrange(user_id, age) |> group_by(user_id) |> filter(n() >= 2) |>
  slice(1:2) |> mutate(visit = row_number()) |> ungroup() |>
  pivot_wider(id_cols = user_id, names_from = visit, values_from = c(age, theta_irt, log_theta, log_gamma)) |>
  filter(age_2 - age_1 >= .25)
cat("\nchildren with two runs >= 3 months apart:", nrow(pairs), " median gap (y):", round(median(pairs$age_2 - pairs$age_1), 2), "\n")
boot_r <- \(f, B = 2000) { v <- replicate(B, { i <- sample(nrow(pairs), replace = TRUE); f(pairs[i, ]) }); quantile(v, c(.025, .975)) }
rr <- list(`2PL stability` = \(d) cor(d$theta_irt_1, d$theta_irt_2), `Q theta stability` = \(d) cor(d$log_theta_1, d$log_theta_2),
           `Q gamma stability` = \(d) cor(d$log_gamma_1, d$log_gamma_2),
           `Q theta1 -> 2PL2` = \(d) cor(d$log_theta_1, d$theta_irt_2), `2PL1 -> Q theta2` = \(d) cor(d$theta_irt_1, d$log_theta_2),
           `2PL stability, age-adjusted` = \(d) cor(resid(lm(theta_irt_1 ~ age_1, d)), resid(lm(theta_irt_2 ~ age_2, d))),
           `Q theta stability, age-adjusted` = \(d) cor(resid(lm(log_theta_1 ~ age_1, d)), resid(lm(log_theta_2 ~ age_2, d))))
retest <- imap_dfr(rr, \(f, nm) { ci <- boot_r(f); tibble(measure = nm, r = f(pairs), lo = ci[1], hi = ci[2]) })

out <- list(reliability = rel, cross = cross, retest = retest, n_persons = length(keep), n_pairs = nrow(pairs))
write_rds(out, here("models/diffirt_rt_information.rds"))
cat("\nSplit-half reliability (mean over", nsplit, "random splits):\n"); print(as.data.frame(mutate(rel, across(where(is.numeric), \(z) round(z, 3)))))
cat("\nCross-half prediction:\n"); print(round(unlist(cross), 3))
cat("\nTest-retest:\n"); print(as.data.frame(mutate(retest, across(where(is.numeric), \(z) round(z, 2)))))
