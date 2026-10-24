# Helpers for the dimensionality and DIF checks on the mental rotation IRT models.
# They rebuild the paper's scalar 2PL (guessing fixed at .5, priors a1 ~ N(1, .3), d ~ N(0, 3),
# parameters shared across the instances of an item class) directly in mirt, so that
# variants (extra factors, freed items, no priors) can be compared with it.

library(mirt)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(tibble)

# Response matrix, group labels and item classes, taken from the model record that
# 02_fit_irt.qmd saved (the record's attributes hold the exact data the paper's models used).
load_mrot_irt_data <- function(path = "models/mrot/multigroup_dataset/overlap_items/mrot_2pl_f1_scalar.rds") {
  a <- attributes(readRDS(path))
  D <- a$data
  rownames(D) <- a$runs
  list(D = D,
       group = factor(a$groups, levels = a$group_names),
       items = colnames(D),
       class = sub("-[0-9]+$", "", colnames(D)))   # "mrot_2d_duck_040-3" -> "mrot_2d_duck_040"
}

# Fit a multigroup 2PL.
#   spec          "uni" (one factor), "two" (correlated 2D and 3D factors), or
#                 "bifactor" (general factor plus a 3D-specific factor)
#   free_classes  item classes whose slope and intercept are free across groups (still equal
#                 across the instances within a group); all other classes are equal across groups
#   priors        apply the paper's priors (FALSE gives unpenalised likelihoods for LR tests)
#   rasch         fix all slopes at 1 (1PL with guessing fixed at .5), as in the paper's Rasch models
#   fix_groups    fix every group's mean at 0 and variance at 1 (one-factor only), as in the paper's
#                 configural and metric models; needed to identify a model with all item parameters free
fit_mrot <- function(dat, spec = "uni", free_classes = character(), quadpts = 61,
                     priors = TRUE, ncycles = 3000, tol = 1e-6, verbose = FALSE,
                     fix_groups = FALSE, rasch = FALSE) {
  is3d <- grepl("_3d_", dat$items)
  model <- switch(spec,
    uni = 1,
    two = mirt.model(paste0("F2D = ", paste(which(!is3d), collapse = ","),
                            "\nF3D = ", paste(which(is3d), collapse = ","),
                            "\nCOV = F2D*F3D")),
    bifactor = mirt.model(paste0("G = 1-", length(dat$items),
                                 "\nS3D = ", paste(which(is3d), collapse = ","))))
  grp <- as.character(dat$group)

  # parameter table; the invariance arguments only serve to get group means/variances
  # freed in all but the first group (and to pass mirt's identification check)
  pars <- multipleGroup(dat$D, model, group = grp, itemtype = "2PL", pars = "values",
                        invariance = c("free_means", "free_var", "slopes", "intercepts"))
  # discard mirt's own cross-group ties; the ones we want are imposed explicitly below
  pars$const <- "none"
  pars$nconst <- "none"
  pars$value[pars$name == "g"] <- 0.5
  pars$est[pars$name %in% c("g", "u")] <- FALSE
  if (rasch) {
    pars$value[pars$name == "a1"] <- 1
    pars$est[pars$name == "a1"] <- FALSE
  }
  if (fix_groups) {
    pars$value[pars$name == "MEAN_1"] <- 0
    pars$value[pars$name == "COV_11"] <- 1
    pars$est[pars$name %in% c("MEAN_1", "COV_11")] <- FALSE
  }

  item_class <- sub("-[0-9]+$", "", pars$item)
  is_item_par <- pars$class == "dich" & pars$name %in% c("a1", "a2", "d")
  cons <- list()
  for (cl in unique(item_class[is_item_par])) {
    for (nm in unique(pars$name[is_item_par & item_class == cl])) {
      idx <- which(is_item_par & item_class == cl & pars$name == nm & pars$est)
      if (!length(idx)) next
      if (cl %in% free_classes) {
        for (g in unique(pars$group[idx])) {
          ii <- idx[pars$group[idx] == g]
          if (length(ii) > 1) cons[[length(cons) + 1]] <- pars$parnum[ii]
        }
      } else if (length(idx) > 1) {
        cons[[length(cons) + 1]] <- pars$parnum[idx]
      }
    }
  }

  # priors go on the first member of each constraint set
  pars$prior.type <- "none"
  pars$prior_1 <- NaN
  pars$prior_2 <- NaN
  if (priors) for (cc in cons) {
    i <- which(pars$parnum == cc[1])
    pars$prior.type[i] <- "norm"
    pars$prior_1[i] <- if (pars$name[i] == "d") 0 else 1
    pars$prior_2[i] <- if (pars$name[i] == "d") 3 else 0.3
  }

  multipleGroup(dat$D, model, group = grp, itemtype = "2PL", pars = pars, constrain = cons,
                method = "EM", quadpts = quadpts, verbose = verbose,
                technical = list(NCYCLES = ncycles), TOL = tol)
}

# Fit summary of one model
fit_summary <- function(m, label) {
  tibble(model = label,
         converged = extract.mirt(m, "converged"),
         n_pars = extract.mirt(m, "nestpars"),
         logLik = m@Fit$logLik, AIC = m@Fit$AIC, BIC = m@Fit$BIC)
}

# Item-class DIF: free one class at a time across groups and compare with the all-invariant
# (scalar) model by likelihood ratio. Unpenalised (priors = FALSE) so that likelihoods are comparable.
class_dif <- function(dat, spec = "uni", quadpts = 61) {
  m0 <- fit_mrot(dat, spec, quadpts = quadpts, priors = FALSE)
  ll0 <- m0@Fit$logLik
  np0 <- extract.mirt(m0, "nestpars")
  map(unique(dat$class), \(cl) {
    m1 <- fit_mrot(dat, spec, free_classes = cl, quadpts = quadpts, priors = FALSE)
    est <- as_tibble(mod2values(m1)) |>
      filter(sub("-[0-9]+$", "", item) == cl, name %in% c("a1", "a2", "d"), str_detect(item, "-1$")) |>
      select(group, name, value) |>
      pivot_wider(names_from = name, values_from = value)
    # the 3D classes load on the second factor in the two-factor model
    est <- est |> mutate(a = if (spec == "two" && grepl("_3d_", cl)) a2 else a1, b = -d / a)
    chisq <- 2 * (m1@Fit$logLik - ll0)
    df <- extract.mirt(m1, "nestpars") - np0
    tibble(item = cl, chisq = chisq, df = df, p = pchisq(chisq, df, lower.tail = FALSE),
           est = list(est |> select(group, a, b)))
  }) |>
    list_rbind() |>
    mutate(p_holm = p.adjust(p, "holm"), p_bh = p.adjust(p, "BH"))
}
