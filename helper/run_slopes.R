# One angle slope (log RT per 40 degrees) per assessment, as in Tables S7 and S8
# of the supplement, for a given stimulus type. Assessments need at least
# min_trials trials overall, and at least three distinct angles and eight
# correct trials of that type, to support a slope. above_chance is the
# binomial screen on the assessment's accuracy over all its trials.

run_angle_slopes <- function(rt_trials, stimulus_type, deg = 40, min_trials = 10) {
  trials <- rt_trials |>
    dplyr::filter(is.finite(log_rt), trial_number != 1, !is.na(angle)) |>
    dplyr::mutate(angle_sc = (angle - mean(angle)) / deg)
  acc <- trials |>
    dplyr::summarise(n_tr = dplyr::n(), n_corr = sum(correct), .by = run_id) |>
    dplyr::filter(n_tr >= min_trials) |>
    dplyr::mutate(above_chance = pbinom(n_corr - 1, n_tr, 0.5, lower.tail = FALSE) < .05)
  trials |>
    dplyr::filter(correct == 1, item_group == stimulus_type) |>
    dplyr::inner_join(acc |> dplyr::select(run_id, above_chance), by = "run_id") |>
    tidyr::nest(d = -c(run_id, site_label, age_group, above_chance)) |>
    dplyr::mutate(slope = purrr::map_dbl(d, \(x) {
      if (dplyr::n_distinct(x$angle_sc) < 3 || nrow(x) < 8) NA_real_
      else coef(lm(log_rt ~ angle_sc, data = x))[["angle_sc"]]
    })) |>
    dplyr::select(-d) |>
    dplyr::filter(!is.na(slope))
}
