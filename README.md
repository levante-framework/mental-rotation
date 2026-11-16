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
| `05_exclusion_sensitivity.qmd` | `data/`, `helper/`, `02`–`04` and the paper's code | `models/mrot_exclusion_sensitivity.rds` (Table S13) |
| `06_dimensionality.qmd` | `models/mrot/` (the 02 overlap-item record) | `models/mrot_dimensionality.rds` (Table S15) |
| `mrot_paper/mrot_paper.qmd`, `mrot_paper/supplementary.qmd` | `data/`, `models/` | the manuscript and supplement |

The run exclusions are defined once, in `helper/filter_runs.R`. `02` and `03` calibrate the IRT models on the same runs the paper analyses. `05` reruns `02`–`04` and the paper's code in temporary directories, once with these exclusions and once keeping every run with a recorded age, and takes about 15 minutes. Rerun it after any change to the analysis; the paper's render stops if its results are out of date.

The committed `data/` and `models/` files are enough to render the paper without rerunning the pipeline.

`01` pins these Redivis dataset versions:

| Dataset | Version |
|---|---|
| `pilot_uniandes_co_rural:bxgv` | v4.0 |
| `pilot_uniandes_co_bogota:d0c5` | v3.0 |
| `pilot_mpieva_de_main:8wjx` | v2.0 |
| `pilot_western_ca_main:bgcj` | v2.0 |

These versions are verified: fetching them reproduces the committed `data/` files exactly (same runs, trials and values), and the committed trial data records its source as these versions in its `redivis_source` column. The datasets were later renamed from `*_processed:<code>` to `*:<code>`; the codes are unchanged.

Render the paper from `mrot_paper/` with `quarto render mrot_paper.qmd` and `quarto render supplementary.qmd`.

## Other inputs

- `data/sex_data_cleaned.rds` is made by `demographics_data/process_demographic_data.R` from the Leipzig and Colombian site demographics files, which are not shared (see `demographics_data/demographics_readme.md`), and from caregivers' reports of sex at birth in `survey/survey_gender_conditions.rds`, the only source for western-ca.
- `survey/survey_gender_conditions.rds` is made by `survey/extract_survey.R` from the caregiver survey data in the `survey-caregiver` repo; it is used only by `mrot_paper/gender_analysis.Qmd`, not by the paper.
