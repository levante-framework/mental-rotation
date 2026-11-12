# Run-level exclusions, shared by the IRT calibration (02, 03) and the paper
# (mrot_paper/_00_data_prep.qmd) so that the models are fit to the same runs
# the paper analyses.
#
# num_attempted is absent for every run collected on task versions before
# 1.0.0-beta.20, which in practice means the May-June 2024 uniandes-co-bogota
# assessments. A missing value therefore marks an early build of the task, and
# those runs are excluded because the early build is not comparable to the
# version every other site was administered.

min_trials <- 10
min_gap_months <- 3

filter_runs <- function(run_data) {
  run_data |>
    dplyr::filter(!is.na(num_attempted)) |>
    dplyr::filter(num_attempted >= min_trials) |>
    dplyr::filter(!is.na(age), age >= 5, age <= 14) |>
    dplyr::arrange(user_id, age) |>
    dplyr::group_by(user_id) |>
    dplyr::mutate(run_number = dplyr::row_number(),
                  age_gap = age - dplyr::lag(age)) |>
    dplyr::ungroup() |>
    dplyr::filter_out(age_gap < min_gap_months / 12)
}
