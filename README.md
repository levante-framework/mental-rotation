# Mental-rotation
Analysis and manuscript code for the mental rotation task

## Setup

R 4.5.0 and Quarto. Package versions are pinned in `renv.lock`; from the project root run

```r
renv::restore()
```

`mrot_paper/.Rprofile` activates the same renv library when the paper is rendered.

## Pipeline

Run the notebooks in order from the project root. Each step reads the outputs of the steps before it.

| Step | Reads | Writes |
|---|---|---|
| `01_fetch_trials.qmd` | LEVANTE Redivis datasets (needs Redivis login) | `data/task_data_nested.rds`, `data/runs_mrot.rds` |
| `02_fit_irt.qmd` | `data/` | `models/mrot/` (model records), `models/mrot_{scores,coef,anova,info}.rds` |
| `03_prior_sensitivity.qmd` | `data/task_data_nested.rds` | `models/mrot_prior_sensitivity.rds` |
| `04_reliability.qmd` | `models/mrot/` | `models/mrot_rxx.rds` |
| `mrot_paper/mrot_paper.qmd`, `mrot_paper/supplementary.qmd` | `data/`, `models/` | the manuscript and supplement |

The committed `data/` and `models/` files are enough to render the paper without rerunning the pipeline. Rerunning `01` fetches the current versions of the datasets, which may differ from the committed snapshot (last fetched 2026-04-09).

Render the paper from `mrot_paper/` with `quarto render mrot_paper.qmd` and `quarto render supplementary.qmd`.

## Other inputs

- `data/sex_data_cleaned.rds` is made by `demographics_data/process_demographic_data.R` from site demographics files that are not shared (see `demographics_data/demographics_readme.md`).
- `survey/survey_gender_conditions.rds` is made by `survey/extract_survey.R` from the caregiver survey data in the `survey-caregiver` repo; it is used only by `mrot_paper/gender_analysis.Qmd`, not by the paper.
