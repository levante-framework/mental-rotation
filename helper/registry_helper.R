# functions for reading the local model registry (models/<task>/<model_set>/<subset>/<file>.rds)
# copied from levante-pilots 02_score_data/02_extract_irt/registry_helper.R

# list models in registry and parse directory structure into metadata
list_models <- \(regdir) {
  mod_files <- list.files(regdir, recursive = TRUE)
  mod_files |>
    str_split("/", simplify = TRUE) |>
    as_tibble(.name_repair = "minimal") |>
    set_names(c("task", "model_set", "subset", "filename")) |>
    bind_cols(path = mod_files)
}

# read in files from path column of model df
load_models <- \(mod_df, regdir) {
  mod_df |> mutate(mod_rec = map(path, \(p) read_rds(file.path(regdir, p))))
}
