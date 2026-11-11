# Build the person x item response and response-time matrices that diffIRT expects.
# Persons are assessments (runs). A run sees some concrete stimuli (item_original) twice, so the
# columns are stimulus x occurrence within the run; the item class (stimulus x angle, 12 in all) is
#   Rscript --vanilla diffirt/01_prepare_data.R [rt_min in seconds, default 0.25; writes data/diffirt_mats[_rtmin<x>].rds]
# kept so parameters can be shared across the columns of a class, as in the paper's IRT models.
suppressMessages({library(dplyr); library(tidyr); library(readr); library(here)})

trials <- read_rds(here("data/mrot_rt_trial.rds"))

args <- commandArgs(TRUE)
rt_min <- if (length(args)) as.numeric(args[1]) else 0.25   # s; faster responses are treated as anticipations/guesses and dropped
suffix <- if (length(args)) paste0("_rtmin", args[1]) else ""
rt_max <- 29.9   # s; trials hit the 30 s time limit

d <- trials |>
  filter(rt_s >= rt_min, rt_s < rt_max) |>
  arrange(run_id, trial_number) |>
  mutate(occ = row_number(), .by = c(run_id, item_original),
         col = paste(item_uid, item_original, occ, sep = "|"))

cols <- d |> distinct(col, item_uid, item_group) |> arrange(item_uid, col)
runs <- d |> distinct(run_id, user_id, site, dataset, adaptive, age) |> arrange(run_id)

to_mat <- \(v) d |> select(run_id, col, all_of(v)) |>
  pivot_wider(names_from = col, values_from = all_of(v)) |>
  arrange(run_id) |> select(-run_id) |> as.matrix() |> _[, cols$col]
rt <- to_mat("rt_s")
x <- to_mat("correct"); storage.mode(x) <- "numeric"

stopifnot(identical(is.na(rt), is.na(x)), nrow(rt) == nrow(runs))
out <- list(rt = rt, x = x, cols = cols, runs = runs, rt_min = rt_min, rt_max = rt_max)
write_rds(out, here(paste0("data/diffirt_mats", suffix, ".rds")), compress = "gz")

cat("persons:", nrow(rt), " items (columns):", ncol(rt), " item classes:", n_distinct(cols$item_uid), "\n")
cat("observed cells:", sum(!is.na(rt)), " dropped trials:", nrow(trials) - nrow(d),
    " (", round(100 * (1 - nrow(d) / nrow(trials)), 1), "%)\n", sep = "")
cat("observations per person: "); print(summary(rowSums(!is.na(rt))))
cat("observations per column: "); print(summary(colSums(!is.na(rt))))
cat("accuracy:", round(mean(x, na.rm = TRUE), 3), "\n")
