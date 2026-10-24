# Recommended changes to the manuscript

Compiled from `suggested_edits.md` and the analyses in `extra_analyses.qmd` (results in the sections named below).
Line numbers refer to `mrot_paper.qmd` and its included files at commit `82fcd5f`. Items are grouped by where the
change goes, and marked **[must]** (a statement that the analyses contradict or that a reviewer will catch), **[should]**
(a gap worth closing) or **[could]** (polish). Evidence is in `extra_analyses.qmd` ("EA §") and `suggested_edits.md` ("SE").

## Abstract and Lay Summary

- **[must]** Replace "ΔBIC = 416 vs. configural" (l.14). The exact value is 416.57, so use "417" (the Table 3 value), but note that the margin shrinks to 117 once the priors are removed (EA §5). Either report the unpenalised comparison or say the comparison is under the paper's priors. Update the `delta_bic` guard in the abstract check (l.468).
- **[must]** Sex: add that boys responded about 7% faster (β = −0.08 log units, 95% CI [−0.13, −0.02], p = .004; EA §7) alongside "θ did not differ by sex". Say "no difference in θ (female − male = −0.002 SD, 95% CI ±0.11 SD)". Apply the same change to the Lay Summary (l.16) and drop "sex differences are absent" (l.432).
- **[should]** Report the angle effect separately for 2D and 3D (2D 0.156, 3D 0.148 per 40°, SE 0.011 and 0.017 with exemplar random intercepts; EA §6) instead of one pooled β, and say the effect is multiplicative ("about 17% slower per 40°"). Avoid "replicated for both 2D and 3D" unless the youngest 3D result is qualified (see Results).
- **[should]** State units for the age effect ("0.33 θ per year, about 0.22 SD") and say the gain slows with age (EA §6).
- **[could]** Report 1,037 children and 1,158 assessments together.

## Introduction

- **[should]** Either restore the sentence at l.86 that poses 2D vs 3D as a research question and add it to the RQs (l.103), or remove the gap from l.85 (SE A7).
- **[should]** Frick et al. (2013) covers ages 3–5, so it does not support improvement "between ages 3–13" (l.89). Cite `marmor1975development` and `kail1980developmental` for the older ages, or narrow the claim.
- **[could]** Check the citations listed in SE C4 (Hetland, Jansen, Lauer's "30,000 children" and g ≈ 0.20, Núñez n = 151). They need the source papers.

## Methods

- **Sample (l.155, SE B9, F5).** **[must]** Fix the exclusion counts. 1,251 children and 1,502 assessments were scored; 344 assessments from 333 children were excluded; 119 of those children kept another valid assessment, so 214 were lost and 1,251 − 214 = 1,037. Report the assessments excluded by reason (age, <10 trials, <3-month gap).
- **Income wording (l.411, l.414, l.432).** **[must]** Colombia is an upper-middle-income country. Replace "two low-to-middle-income sites from the Global South" with wording that matches the data (for example "sites in Colombia, an upper-middle-income country, including a rural sample"). Make the "Western", "WEIRD" and "Global South" terms consistent (SE C3).
- **SES (l.150, l.153 vs l.155).** **[should]** The text says participants came from middle- to upper-middle-income backgrounds, then says no SES data exist. Cite the source or soften.
- **Task description (l.171).** **[should]** Add an item table: 12 item classes (duck 40/80/120/160°, rabbit 20/40/80/120/160°, 3D shape 40/80/120°), the number of concrete exemplars per class (68 in total), and how many a child sees. Explain that rotations beyond 180° are recoded to the shorter path, and say which axis the 3D rotation uses (SE A4).
- **IRT (l.188–195).** **[must]** Say that guessing is fixed at .5, so the "2PL" and "Rasch" models are really 3PL and 1PL with fixed guessing. State that priors are N(1, 0.3) on slopes and N(0, 3) on intercepts and whether the second number is an SD or a variance (SE B8).
- **IRT model comparison (l.195).** **[must]** Add a prior-sensitivity analysis (EA §5): likelihoods without the priors, and the unpenalised likelihood-ratio test. Say how convergence was checked (the paper's configural model reproduces with the priors; without them it had not converged after 6,000 EM cycles).
- **Dimensionality (l.188).** **[should]** Replace "all models assumed a single underlying factor, following standard practice" with a test: a two-factor (2D, 3D) model improves BIC by 293 points over the one-factor model, and a general plus 3D-specific model by 307 (EA §3).
- **RT model (l.198).** **[should]** List all fixed effects (trial number, adaptive × stimulus) and the random effects. Add the exemplar random intercept (EA §6) or justify leaving it out. Say the model converged without singularity warnings. State the adaptive-format check as the adaptive × angle interaction in the full model (below).
- **Adaptive-format check (l.204–205).** **[must]** The sentence "does not differ significantly (Δβ = 0.011, SE = 0.008, t = 1.3)" comes from a model with no stimulus, site or age terms. In the full model the interaction is −0.019 (SE 0.010, t = −1.93, LRT p = .055), with adaptive runs flatter. Report that, and drop "no bias" language (EA §6).
- **Ability model (l.208, l.339).** **[must]** Describe the model actually fitted (`age * sex * site_label`, all interactions), and state the SD used for "SD per year" (pooled SD of θ = 1.48; it includes between-site differences).
- **Sex RT model (l.211).** **[should]** It is not "the same angular sensitivity model" (it drops `trial_number` and `adaptive` and adds a five-way interaction). Describe it accurately.
- **Age.** **[should]** Say that age enters linearly and report that a quadratic term improves fit (θ: p < .001; RT slope: p = .008; EA §6), or switch to a spline.
- **Reliability (l.222).** **[must]** See Results.

## Results

- **Table 3 (l.222–230).** **[must]** Rebuild the table with converged fits and either unpenalised log-likelihoods or a footnote that they are penalised and so not comparable across invariance levels. In the current table the 2PL configural model (−21643) is worse than the metric model (−21579) and the Rasch configural model (−21636). Add AIC to the text and say AIC prefers the metric model (43278) over scalar (43411), or configural when priors are removed. Replace "best fit" at l.220 with a statement that matches both criteria. Define "overlapping items".
- **Invariance wording (l.220–226).** **[must]** Change "scalar invariance was supported" to approximate or partial invariance. Without priors, exact scalar invariance is rejected (χ²(66) = 365), and under the two-factor model only 2D duck 40° and 3D shape 40° show DIF after Holm correction (EA §4). Say the one-factor DIF results (6 of 12 flagged) are inflated by the misspecified model. Delete "the absolute spacing … is also preserved", which restates the constraint.
- **Reliability (l.222).** **[must]** Delete "2PL provides substantially higher marginal reliabilities (2PL: …; Rasch: …)". The 0.32 vs 0.89 gap is an artefact of `mirt::marginal_rxx`, which uses the fitted latent variance without rescaling. Scale-free versions are 0.89–0.93 (2PL) against 0.90–0.93 (Rasch); empirical reliability is 0.82–0.89 for both (EA §5). Report one scale-free value per site in a table. The paper's reliabilities use the 81-item models, while Table 3 uses the 54-item overlap models, so say which.
- **Angle effect and Table 4 (l.254–290).** **[must]** Lead with the common-angle 2D vs 3D contrast, not the full-range one (Δ = 0.00, p = .906), which the text calls an artefact. Report that 3D − 2D = +0.027 (p = .003) overall but +0.060 at mpieva-de and about 0 elsewhere (site heterogeneity p = .006; EA §1). Put the 3D weighting sensitivity (0.155 → 0.115 under balanced weights) in the main text.
- **Adaptive row of Table 4.** **[must]** Remove it or footnote it as a composition-dependent contrast, not a format effect (EA §6).
- **RMSE (l.255, l.350, l.340).** **[must]** `exp(RMSE)` is a multiplicative factor, not seconds. Write "RMSE = 0.58 log units (a typical residual factor of 1.79)". Add units to the ability-model RMSE.
- **Linear vs non-linear (l.267).** **[must]** The paragraph says Fig 1 suggests non-linearity, then says Fig S6 supports a linear term. Fig S6 only tests mirror symmetry, and the symmetry is imperfect (200° is about 0.12 log units slower than 160°; 320° is faster than 40°; the supplement says the peak is at 200°). Say "broadly consistent with shortest-path recoding", and either compare a factor-coded angle with the linear fit or test the sensitivity to dropping the 160° cells.
- **Site and age (l.264, Fig 1).** **[must]** Add the site × age-group × stimulus slope table (EA §6). Slopes rise with age everywhere, but for 5–7 year-olds on 3D items the slope is not distinguishable from zero in Bogotá (0.016) and at the rural site (0.030). Qualify "replicates robustly across all four sites".
- **Accuracy.** **[should]** Add a short accuracy-by-angle result (accuracy falls about 6 points per 40° for 2D and 7 for 3D at every site, and on fixed-form runs alone; EA §2), since the Methods promise accuracy and latency (l.171).
- **Guessing and the age gradient.** **[should]** Add the sensitivity analysis (EA §2): the age gradient in the angle slope survives every exclusion (difference 0.060–0.096, all p < .001) but is smallest when only above-chance runs are kept.
- **Sex on θ (l.339–345).** **[must]** Add a CI ("female − male = −0.002 SD, 95% CI ±0.11 SD") and a statement of what it excludes (effects ≥ 0.11 SD, including g ≈ 0.20). Report sex × site (p = .33) and per-site CIs (±0.16 to ±0.28 SD; EA §7).
- **Sex on RT (l.352).** **[must]** Report the faster boys in the Abstract and Discussion. "This effect holds within stimulus type" is true for 2D (−8.0%, p = .002), but for 3D it is −5.7% with p = .0499 under observed-trial averaging and p = .103 under the balanced grid, so say so. Fix "This effects holds" and "boys being … being".

## Discussion and Conclusion

- **[must]** Remove "common/universal" (l.411) and "the same general set of spatial abilities" (l.432). Say "shared across these sites".
- **[must]** Revise the invariance paragraph (l.411–414) to match the Results: approximate rather than exact scalar invariance, a two-dimensional structure, and DIF concentrated in the 40° classes.
- **[must]** Sex (l.411, l.425, l.432): drop the claim that the null sex result is part of the validity evidence, replace "held across all four sites" with the sex × site test and CIs, and discuss the 7% RT advantage (speed–accuracy trade-off, device or familiarity effects, strategy). Reconcile "consistent with the meta-analytic picture" with Lauer's g ≈ 0.20 using the CI.
- **[must]** mpieva-de paragraph (l.419): the argument that steeper slopes follow from slower baselines cannot hold in a log-RT model, where slopes are already proportional. Say the larger 3D − 2D difference and steeper slope at mpieva-de are unexplained, and offer format, device timing or age mix as hypotheses.
- **[should]** Age (l.423): note that older children show steeper proportional slopes, the opposite of the usual finding that rotation rate speeds up with age. Offer the log-scale and guessing explanations, and cite the guess-robust analysis (EA §2). Say the θ gain per year slows from 0.55 at age 5 to 0.08 at 13.
- **[should]** Replace "spatially continuous transformation" (l.417) with a statement that only a monotonic dependence is shown.
- **[should]** Limitations (l.429): add administration mode and device confounded with site, CAT vs fixed form (the rural site is CAT only), sex missing for 199 children, the 3D evidence resting on three angle classes, no strategy data, and a two-factor structure that the one-factor θ ignores.
- **[should]** Reconcile "foundation for meaningful cross-cultural comparisons" (l.432) with l.101: invariance supports comparing relations (age slopes), not absolute levels. Reconsider the title word "comparison".

## Supplement

- **[must]** Fig S2 caption: "3D items are … less discriminating" holds only at 40° (3D 1.18 against 1.60 duck and 1.46 rabbit). At 80° and 120° the 3D values (1.66, 1.83) lie within the 2D range. Discrimination rises with angle for 3D, so the caption's other claim holds.
- **[should]** Fig S5: the y-axis says "Reaction time (s)" but the values are log seconds. Use "response" throughout.
- **[should]** Table S1: keep `age_group` as a factor so rows sort 5–8 first. Use one age-label scheme.
- **[should]** Fig S3 and S4 (item parameters across sites): say whether they come from the penalised or unpenalised configural model. A reviewer reads large 3D departures from them (shape 120° difficulty about 7 at Bogotá, shape 40° discrimination about 0.4 at the rural site; I did not check these values). Unpenalised configural slopes are unstable in sparse cells, so describe them as imprecise rather than as evidence of non-invariance.
- **[could]** Replace the hard-coded numbers in `supplementary.qmd` (SE E3) with inline code, and remove the duplicated `rt-angle-data` chunk (SE E4).

## Typos and small fixes

l.10 `<hhttps://` → `<https://`; l.12 "The author has" → "The authors have"; l.83 "tasks … presents"; l.150 "Leipzig a mid-sized" → "Leipzig is a mid-sized"; l.153 "most population" → "most populous"; l.147 "Chiquinquira" → "Chiquinquirá"; l.352 "This effects holds", "boys being … being"; the "sex.147" footnote marker (check the render); Fig 1 caption uses "points" for two things; Fig S2 caption θ missing in the render (the source has it). Also set `fmt_p` to print three decimals (SE B10).

## Not resolved

- Citation checks that need the source papers (above).
- The metric-invariance row of Table 3 was not refit here.
- Whether to adopt partial invariance (free the 40° classes) for the final θ scores. This is a modelling choice for the authors.
