# Reconciliation of `recommended_changes.md` against main

Compares George's `recommended_changes.md` (branch `paper-review-suggested-edits`,
commit `5dc5fd4`) with the state of the manuscript at `7b4c6fc` on `main`. George's
status section was written against `8ef51d8`, so it does not know about the changes
in `7b4c6fc`; this file records which of his items that commit closed, which it did
not, and the two places where our analysis and his disagree.

Priority markers are his (`[must]`, `[should]`, `[could]`).

## Closed by `7b4c6fc`

| Item | Where |
|---|---|
| **[must]** Fix the exclusion counts and report assessments by reason | Methods. His arithmetic and ours agree exactly: 1,251 children, 1,502 assessments, 344 excluded, 214 children lost, 1,037 retained |
| **[must]** Add a prior-sensitivity analysis | Supplement S1, sweeping the slope prior over 0.3/0.5/1/2/none |
| **[must]** Table 3 log-likelihoods are penalised and not comparable | Table now reports `logPost`; the caption explains that the configural model carries more prior terms |
| **[must]** Remove or footnote the adaptive row of Table 4 | Row removed; a code comment records why |
| **[must]** `exp(RMSE)` is a factor, not seconds | Both RT models now read "on the log scale, equivalent to a multiplicative error of about X×"; the ability model reports "units of ability" |
| **[must]** Add a CI to the sex effect on theta | Results give the estimate, 95% CI, and what it excludes |
| **[must]** Report sex x site | New Table 5, per-site estimates with CIs, plus an LRT for the interaction |
| **[must]** State that guessing is fixed at .5 | Methods name the models as 1PL-G and 2PL-G and give both priors |
| **[should]** Add an accuracy-by-angle result | New Results paragraph and supplement S9 |
| **[should]** Add the guessing sensitivity analysis on the age gradient | Supplement S7 and S8, now including a binomial above-chance screen alongside the flat cut-offs |
| **[should]** Table S1 should keep `age_group` as a factor and use one age-label scheme | Age bands relabelled to the ages they contain and kept as factor levels throughout |
| Typos: `hhttps`, "The author has", "Leipzig a mid-sized", "This effects holds" | Fixed |

## Open, and substantive

### 1. Reliability — RESOLVED, he was right

`7b4c6fc` kept the sentence "Marginal reliabilities are also much higher under the
2PL model" and added an explanation: that the Rasch model fixes discriminations at 1,
so its items "carry little information". George says the gap is an artefact of
`mirt::marginal_rxx`, which integrates test information against a standard normal
regardless of the fitted latent variance.

Recomputed independently from the saved model records:

| Model | Site | mean a1 | var(theta) | `marginal_rxx` | Corrected |
|---|---|---|---|---|---|
| 2PL | mpieva-de | 1.78 | 1.00 | 0.890 | 0.890 |
| 2PL | bogota | 1.78 | 2.34 | 0.778 | 0.900 |
| Rasch | mpieva-de | 1.00 | 6.24 | 0.317 | 0.925 |
| Rasch | bogota | 1.00 | 5.70 | 0.337 | 0.900 |

The first row settles it. Where the fitted variance is exactly 1, `marginal_rxx` and
the corrected value agree; everywhere else they diverge, and the divergence tracks
var(theta). The Rasch constraint forces the latent scale to stretch to var ~ 6, and
`marginal_rxx` then evaluates reliability as though it were 1.

Corrected, the reliabilities are 0.89 (2PL) against 0.93 (Rasch), and empirical
reliabilities from EAP scores are 0.82 against 0.83. There is no gap to explain.

**The mechanism, precisely.** `mirt::marginal_rxx` integrates `TI / (TI + var_theta)`.
Marginal reliability is true variance over true plus error variance, which with a
conditional error variance of `1/TI` is `v*TI / (v*TI + 1)`, equivalently `TI / (TI + 1/v)`.
The function uses `v` where `1/v` belongs. The forms coincide exactly when `v = 1`.
A limiting case settles which is right: hold information fixed and let `v` grow, and
reliability must approach 1, which the first form does and `TI/(TI + v)` does not.

Note this is not a misuse of the `density` argument. Passing `mean` and `sd` changes
only the weighting density and not the ratio, and makes the Rasch figure *worse*
(0.317 to 0.281). The mirt changelog records the same issue being fixed for
`plot(mod, type = 'rxx')` in version 1.21 but never for `marginal_rxx`, and no entry
touches the function at any version, so 1.46.1 behaves as 1.44.0 does here. Worth
reporting upstream.

**Resolved as follows.**

- `helper/reliability.R` adds `marginal_rxx_fitted()`, with the derivation in comments.
- `04_reliability.qmd` regenerates `models/mrot_rxx.rds` from the saved model records
  without refitting, adding `var_theta`, `rxx_fitted` and `rxx_empirical`. It asserts
  that the default and corrected values agree exactly where `var_theta` is 1 and
  nowhere else, which is the check that identifies the discrepancy as formulaic.
- The reliability chunk moved from `_01_irt.qmd` to `_00_data_prep.qmd` so the main
  text and the supplement read the same numbers; the supplement includes only `_00`.
- Results now report 2PL reliability of 0.89 to 0.93, EAP-based 0.82 to 0.87, note the
  81-item basis, and state that reliability does not distinguish the model types, so
  the 2PL preference rests on fit alone.
- New supplement section and Table S12 give both computations for both models with
  `var_theta` alongside.

### 2. Adaptive-format check — RESOLVED, he was right

The paper reports "The estimated angle slope does not differ significantly between
the two formats (dBeta = 0.011, SE = 0.008, t = 1.3)" and concludes that three checks
"suggest it does not" bias the angle effect. That estimate comes from
`log_rt ~ angle_sc * adaptive + (1 + angle_sc | user_id)`, which has no stimulus, site
or age terms. Adaptive administration is confounded with site, because uniandes-co-rural
is adaptive throughout.

Refitting on the same data (38,571 trials, 1,037 children):

| Model | angle x adaptive | SE | t | p |
|---|---|---|---|---|
| Simple, as reported in the paper | **+0.0108** | 0.0083 | 1.30 | — |
| Full model + `angle_sc:adaptive` | **-0.0189** | 0.0098 | -1.93 | .055 (LRT) |

The sign reverses. Once stimulus, site and age are in the model, adaptive runs are
*flatter* by about 0.019 log units per 40 degrees, and the interaction is marginal
rather than clearly null. This reproduces George's figures exactly.

The within-site check added in `7b4c6fc` (`angle_sc * adaptive * site_label`,
difference 0.011, p = .270) removes the site confound but still omits stimulus and age,
so it does not settle the question either.

**Resolved as follows.** `_02_angle_sensitivity.qmd` now fits `cat_angle_mod`, the full
model plus the angle-by-format interaction, and extracts the coefficient and LRT. The
Methods keep the concern and the accuracy-by-angle exposure check but no longer claim
"three checks suggest it does not do so here"; they point forward instead. A new Results
paragraph, placed directly after the headline angle slope, gives all three estimates and
states that the comparison is not settled, closing on the point that format cannot be
separated from site on the full sample because uniandes-co-rural is wholly adaptive.

The computation sits in `_02` rather than `_00` because the Methods text precedes the
`_02` include, so the full model is not available there; moving the reporting to the
Results avoided refitting a several-minute model twice.

### 3. The ΔBIC margin depends on the priors

The abstract reports ΔBIC = 417 and S1 documents the prior sweep, but the abstract does
not say the margin falls to about 117 when the priors are removed. Half closed.

## Open, wording and smaller items

Done since:

- **[must]** The replication claim in the Discussion is now qualified, noting the 3D
  slope is not distinguishable from zero among the youngest children at either
  Colombian site. The other two "across all four sites" instances are
  research-question framings rather than claims and were left alone.
- **[must]** "sex differences are absent" in the Conclusion now reads that no
  difference is detectable and that the data are inconsistent with one larger than
  about 0.11 SD, with the bound taken from `ability_sex_ci` rather than typed.
- **[must]** "the same general set of spatial abilities" is now "a common spatial
  capacity".
- **[should]** "spatially continuous transformation" is now "a transformation of
  object orientation whose cost rises monotonically with angular disparity".
- Typos "most population" and "Chiquinquira" fixed.

Not applicable or already satisfied:

- The sex-by-site claim at the Discussion is now supported by Table 5, which postdates
  his status section. Per-site estimates, CIs and the interaction LRT are all reported.
- The Discussion does not contain "scalar invariance was supported"; it already states
  that scalar invariance establishes metric comparability rather than deeper equivalence.
- "being on average" is not an error; his own notes record that typo as done on main.

Resolved by the prior-sensitivity work already in the supplement:

- **[must]** Invariance wording. The Results already report that the rejection of
  configural invariance holds under every prior examined while the metric-versus-scalar
  choice does not, and the Discussion already claims invariance "at least at the metric
  level". Supplement S1 reaches this by refitting all five models across five prior
  settings, where his check refit two models under two. One phrase in the Discussion
  that presupposed scalar invariance was changed to refer to invariance at this level.
- **[must]** The delta-BIC margin. The Abstract now gives 417 under the paper's priors
  and at least 122 across the range examined, both covered by the abstract guard. The
  figures in S1 were typed and are now computed, with the range shared via
  `_00_data_prep.qmd` so the Abstract, Results and supplement quote one source.

His figures were checked for internal consistency rather than refit, since refitting
needs `mirt` in the project library. The BIC gaps reconcile exactly with the reported
log-likelihoods, and the dimensionality log-likelihood gain implies a BIC sample-size
penalty consistent with N = 1,502. He also notes the no-prior configural model had not
converged after 6,000 EM cycles, which makes his rejection of scalar invariance
conservative. He did not refit the metric model, which matters because without priors
BIC favours metric rather than scalar.

## Declined

- **[should]** Dimensionality. His two-factor comparison improves BIC by 293 over the
  one-factor model, with 2D-3D factor correlations of 0.42 to 0.75. Ruled out of scope
  for this paper, which addresses three specific research questions rather than full
  psychometric validation of the instrument.

## Not assessed here

His Results items on the linear-versus-nonlinear paragraph, the site x age x stimulus
slope table, leading with the common-angle contrast, and the Figure S3/S4 captions were
not checked line by line. The 2D/3D angle percentages were added to the Results in
`7b4c6fc` for the shared 40-120 degree range; note his figures (2D 0.156, 3D 0.148) come
from a model with exemplar random intercepts and do not match the paper's (2D 0.14,
3D 0.16), so the two need reconciling before either is quoted.

## Incidental

`filter_out`, used in `_00_data_prep.qmd`, is exported by the renv library's `dplyr`
and not by the system `dplyr` or by `rlevante`. The data prep therefore cannot be run
outside the activated project library, which is what made George's own
`checks/prep.R` fail here. Worth noting alongside the outstanding `renv::restore()`.
