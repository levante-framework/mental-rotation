# Bound on the sex difference in ability (male - female), overall and by age
# band. Shared by the Results (_03_sex_diffs.qmd) and Table S14.
#
# Differences are scaled by the residual SD of ability after age x site, not by
# the total SD: the total SD includes differences between sites and ages, which
# are not part of the variation a sex difference is measured against, and so it
# makes the bound look tighter than it is. The "latent" columns also correct for
# the reliability of the EAP scores, whose differences shrink by about the
# reliability while their SD shrinks by its square root.

sex_ability_bounds <- function(model, data, reliability) {
  sd_resid <- sd(resid(lm(ability ~ age * site_label, data = data)))
  bound_by <- function(by) {
    marginaleffects::comparisons(model, newdata = data, re.form = NA,
                                 variables = "sex", by = by) |>
      tibble::as_tibble() |>
      dplyr::transmute(group = .data[[by]],
                       est = estimate, lo = conf.low, hi = conf.high, p = p.value,
                       est_sd = est / sd_resid, lo_sd = lo / sd_resid, hi_sd = hi / sd_resid,
                       est_latent = est / (sd_resid * sqrt(reliability)),
                       lo_latent = lo / (sd_resid * sqrt(reliability)),
                       hi_latent = hi / (sd_resid * sqrt(reliability)))
  }
  list(sd_resid = sd_resid, overall = bound_by("task"), by_age = bound_by("age_group"))
}
