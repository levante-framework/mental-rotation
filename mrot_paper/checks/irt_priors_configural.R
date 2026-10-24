# Effect of the priors on the configural vs scalar comparison (Table 3 of the paper).
# Configural = all item parameters free across datasets, every group's mean fixed at 0 and variance
# at 1, as in the paper's configural model. Writes models/mrot_prior.rds.
library(here)
library(readr)
source(here("helper", "irt_checks.R"))
dat <- load_mrot_irt_data(here("models/mrot/multigroup_dataset/overlap_items/mrot_2pl_f1_scalar.rds"))
allc <- unique(dat$class)

fits <- list(
  "Configural, with priors (paper)" = fit_mrot(dat, "uni", allc, priors = TRUE,  fix_groups = TRUE, ncycles = 6000),
  "Configural, no priors"           = fit_mrot(dat, "uni", allc, priors = FALSE, fix_groups = TRUE, ncycles = 6000),
  "Scalar, with priors (paper)"     = fit_mrot(dat, "uni", priors = TRUE),
  "Scalar, no priors"               = fit_mrot(dat, "uni", priors = FALSE))

prior_fit <- imap(fits, \(m, label) fit_summary(m, label)) |> list_rbind()
cn <- fits[["Configural, no priors"]]; sn <- fits[["Scalar, no priors"]]
prior_lrt <- tibble(chisq = 2 * (cn@Fit$logLik - sn@Fit$logLik),
                    df = extract.mirt(cn, "nestpars") - extract.mirt(sn, "nestpars")) |>
  mutate(p = pchisq(chisq, df, lower.tail = FALSE))
write_rds(list(fit = prior_fit, lrt = prior_lrt), here("models/mrot_prior.rds"), compress = "gz")
print(as.data.frame(prior_fit)); print(prior_lrt)
