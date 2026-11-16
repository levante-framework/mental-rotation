# The 3D - 2D angle-slope contrast at the angles both stimulus types share,
# under the paper's model and two checks: adding a random intercept for each
# stimulus image, and restricting to adaptive (CAT) runs, where 3D items appear
# throughout the session rather than only at the end. Shared by the Results
# (_02_angle_sensitivity.qmd) and Table S16, so the two cannot disagree.
#
# lme_data is the RT model data built in _02 (and mirrored in the supplement),
# which must carry item_original, the image id.

slope_contrast_checks <- function(lme_data, deg = 40) {
  stopifnot("item_original" %in% names(lme_data))
  shared_angles <- lme_data |>
    dplyr::distinct(item_group, angle) |>
    dplyr::count(angle) |>
    dplyr::filter(n == dplyr::n_distinct(lme_data$item_group)) |>
    dplyr::pull(angle)
  prep <- function(d) {
    d <- d |>
      dplyr::filter(angle %in% shared_angles) |>
      dplyr::mutate(angle_sc = (angle - mean(angle)) / deg) |>
      droplevels()
    contrasts(d$site_label) <- contr.sum(levels(d$site_label))
    contrasts(d$stimulus) <- contr.sum(levels(d$stimulus))
    d
  }
  all_runs <- prep(lme_data)
  cat_runs <- prep(dplyr::filter(lme_data, adaptive == "TRUE"))
  ctrl <- lme4::lmerControl(optimizer = "bobyqa")
  fixed <- log_rt ~ angle_sc * stimulus * site_label * age_sc + trial_number * stimulus
  fits <- list(
    main  = lme4::lmer(update(fixed, . ~ . + adaptive * stimulus + (1 + angle_sc | user_id)),
                       data = all_runs, REML = FALSE, control = ctrl),
    image = lme4::lmer(update(fixed, . ~ . + adaptive * stimulus + (1 + angle_sc | user_id) +
                                (1 | item_original)),
                       data = all_runs, REML = FALSE, control = ctrl),
    cat   = lme4::lmer(update(fixed, . ~ . + (1 + angle_sc | user_id)),  # adaptive is constant here
                       data = cat_runs, REML = FALSE, control = ctrl)
  )
  data_for <- list(main = all_runs, image = all_runs, cat = cat_runs)
  purrr::imap(fits, \(m, nm) {
    d <- data_for[[nm]]
    s <- marginaleffects::slopes(m, newdata = d, re.form = NA, variables = "angle_sc",
                                 by = "item_group")
    stopifnot(identical(as.character(s$item_group), c("2d", "3d")))  # b1 = 2D, b2 = 3D
    h <- marginaleffects::hypotheses(s, hypothesis = "b2 - b1 = 0")
    tibble::tibble(check = nm, runs = dplyr::n_distinct(d$run_id), trials = nrow(d),
                   slope_2d = s$estimate[1], slope_3d = s$estimate[2],
                   estimate = h$estimate, std.error = h$std.error, p.value = h$p.value)
  }) |> purrr::list_rbind()
}
