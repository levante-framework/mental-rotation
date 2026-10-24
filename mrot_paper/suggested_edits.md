# Suggested edits: "Mental rotation in children aged 5–13" (`mrot_paper.qmd`)

Review of the manuscript, its included analysis files (`_00`–`_03`) and `supplementary.qmd`.
Line numbers refer to the files as of commit `82fcd5f`. I did not re-render the paper. A few claims were checked
directly against `data/*.rds`, and those are marked **(checked)**.

Items are ordered by how much they could change a reviewer's opinion: A = substantive, B = analysis/reporting,
C = framing/writing, D = typos, E = code/reproducibility.

---

## A. Substantive issues (address before submission)

**A1. The significant sex difference in RT is missing from the Abstract, Discussion and Conclusion.**
Results (l.352) call it "a relatively small but robust effect of sex" on response time, with boys different from girls on
average and the effect holding within 2D and 3D. The Abstract (l.14), Lay Summary (l.16: "we found no difference between boys and girls"),
Discussion (l.425) and Conclusion (l.432: "sex differences are absent") all say there is no sex difference, and the Discussion never mentions the RT result.
- Report both findings everywhere: no difference in θ, a small RT difference.
- Add a Discussion paragraph on what the RT difference could mean: speed–accuracy trade-off, device or
  familiarity effects, or a sex difference in strategy. State which sites and ages it holds in.
- Change "did not differ by sex" in the Abstract to something like "θ did not differ by sex, although boys responded
  [faster/slower]".

**A2. A null sex result is used as evidence of cross-cultural validity.**
The Discussion (l.411, l.425) and Conclusion treat the absence of a sex difference as part of "three distinct levels" of evidence
that the task captures a consistent construct. A null result in children doesn't validate the task, because adults show a robust male advantage.
Three further problems:
- The claim that "the null finding held across all four international study sites" (l.425) is not supported by anything in the paper. Site-specific
  sex contrasts are commented out in `_03` (l.284–290), and the model's sex × site terms are never reported.
- The sex sample is 63% Colombian (525 of 838 children with known sex) **(checked)**, and sex is missing for 199 children (98 mpieva-de,
  65 western-ca, 36 uniandes-co-rural). The paper acknowledges the composition but still generalises "across all four sites".
- The paper cites @lauer2019development as finding a small male advantage from about age 6 (g ≈ 0.20, l.91), then
  calls the null "consistent with the meta-analytic picture" (l.425). It is consistent only if the CI excludes g ≈ 0.20.

  Fix: report the sex effect with a 95% CI converted to SD units (β = −0.01, SE = 0.09 in θ units), add an equivalence test
  or Bayes factor against a smallest effect of interest (for example d = 0.2), report sex × site estimates, and
  reframe the sex analysis as descriptive. Drop it from the list of validity evidence in the Discussion and Conclusion.

**A3. Unidimensionality and item-level invariance are assumed rather than tested.**
- l.188: "All models assumed a single underlying factor, following standard practice." Yet the supplement shows 3D items are
  less discriminating than 2D items (Figure S2 caption), and the paper emphasises 2D vs 3D differences. Compare
  against a two-dimensional (2D/3D) or bifactor model, and report model-fit and local-dependence statistics (M2/RMSEA, S-X², residual correlations).
- Scalar invariance is supported only by BIC (l.195, l.220). BIC with N ≈ 1,000 heavily favours parsimony.
  Add likelihood-ratio tests (config → metric → scalar), AIC alongside BIC, and a DIF analysis for individual items
  (for example freeing each item in turn). Say how many items, if any, show non-trivial DIF.
- The claim that the "absolute spacing between [items] on the latent scale is also preserved" (l.224) restates what the difficulty
  constraint means. It isn't an extra finding. Reword.
- The grouping variable is the dataset, with uniandes-co-bogota and uniandes-co-rural as separate groups (`mrot_models` filters
  `model_set == "multigroup_dataset"`, with `multigroup_site` also existing). Say which grouping is used and why.
- Table caption l.230 says "overlapping items", but the Methods never define which items overlap across sites or how many there are.

**A4. The paper never says how many items and stimulus exemplars the task has.** **(checked; corrected after follow-up analysis)**
The IRT model has 12 item classes (stimulus × angle): duck {40, 80, 120, 160}, rabbit {20, 40, 80, 120, 160} and 3D shape {40, 80, 120}.
Each class pools several concrete exemplars (2 to 4 per 2D class, 11 to 12 per 3D class) whose parameters are constrained equal.
(An earlier version of this review said the task had "only 12 items, one exemplar each". That was wrong.) Still missing from the paper:
- The number of classes and exemplars, and how many exemplars a child sees per class (up to 7 per run). Add an item table to Methods:
  stimulus × angle, number of exemplars, number of administrations.
- Exemplar-level variation is not modelled (no item random effects in the RT or accuracy models; IRT shares parameters within class),
  so say that inferences generalise over children but not over exemplars.
- The 3D evidence rests on 3 angle classes (40°, 80°, 120° after recoding), all derived from rotations above 180°. State the rotation axis
  (picture plane vs depth) for the 3D items.
- The Measure section says angles range "from 20° to 320°" (l.171), but the analysis uses 20–160°. Explain the recoding here too.

**A5. Accuracy, the second classic mental-rotation DV, is not analysed, and guessing may contaminate the RT slopes.**
The Methods promise to examine "both accuracy and response latency" (l.171). Only RT on correct trials is analysed.
- Add an accuracy-by-angle mixed logistic model (stimulus, site and age), or at least report accuracy by angle and age.
- This is a threat to the age finding. The task is two-alternative, so correct trials include lucky guesses (50%). Younger
  children who guess fast on hard items would flatten their RT–angle slope, which could produce the reported age gradient (steeper
  slopes with age) without any real change in rotation. Add a sensitivity analysis excluding fast responses (for example < 500 ms)
  and/or children at chance on 3D items, and show whether the age × angle effect persists.
- Relatedly, the lower RT bound of 100 ms (l.183) is far too lenient for a two-alternative choice task with children.
  Justify it or tighten it, and report how many trials each exclusion removes.

**A6. The interpretation of the angle effect as "spatially continuous transformation" is too strong.**
- The Discussion (l.417) infers that the process indexed is "the spatially continuous transformation of object orientation." Yet the same
  paragraph concedes that only a monotonic dependence replicates, and the supplement says the linear chronometric function "is not adjudicated".
  A monotonic RT–angle increase is also what feature-comparison or other non-analog strategies would produce.
- The Abstract frames it as "The angular disparity effect (Shepard and Metzler, 1971) replicated" with "approximately 16.9% slower per 40°". That is a multiplicative
  effect on a log scale, not the original additive result. Say so in the Abstract or soften "replicated".
- l.267 notes visible non-linearity but doesn't test it. Add a model with a quadratic or factor-coded angle term and compare it with the linear fit.
- Give the additive estimate (ms/degree, currently only in Table S4) in the main Results, so readers can compare with
  published rotation rates.
- Please also explain the direction of the age finding. Older children have steeper multiplicative slopes (l.265, l.423), whereas
  the developmental literature usually reports faster rotation rates with age. Offer an interpretation (strategy shift? guessing artefact per A5?), or at least note the tension.

**A7. The 2D vs 3D question is raised in the Introduction but never posed as a research question.**
l.85 sets up "whether the angular disparity effect holds comparably for 2D and 3D stimuli" as a gap, and the sentence that would introduce
it is commented out (l.86). The three RQs (l.103) don't mention it. The results are then partly ambiguous: the full-range slope contrast is null,
and the common-angle contrast is "slightly steeper for 3D" (l.261). The Abstract just says the effect "replicated for both 2D and 3D stimuli"
but reports a single pooled β.
- Either add the 2D vs 3D comparison as an explicit RQ (restore l.86) with a clear one-sentence answer, or remove the gap from the Introduction.
- Report slopes by stimulus type (2D, 3D) in the Abstract, not just the pooled β. The Discussion claims the effect "replicates robustly for both 2D and 3D stimuli across all four
  sites" (l.411), but no site × stimulus slopes are shown. Add them (a small table or a figure panel), especially for sparse 3D cells.

**A8. Site is confounded with administration mode, and this is missing from the Limitations.**
The qualitative site table (`tbl-participants-qualitative`) shows testing location (home / school group / lab), device and setting vary one-to-one with site. The paper partly
acknowledges this in the mpieva-de paragraph (l.419) but not in the Limitations (l.429), which lists only representativeness, sample size and the
cross-sectional design. Add: administration mode and device confounded with site (and device-dependent RT timing error at mpieva-de); no SES or
language data; CAT vs fixed form (and uniandes-co-rural being CAT-only); sex missing for 199 children; 3D evidence limited to three angle classes; no strategy data.

**A9. The "universal" and "same cognitive abilities" language overreaches.**
- l.411: "a common/universal spatial reasoning construct"; l.432: children in three cities "are, by and large, making use of the same general set
  of spatial abilities". Scalar invariance in a four-site, three-country sample licenses neither (the paper says so itself at l.226 and l.414). Replace "universal" with
  "shared across these sites".
- The Conclusion says the findings provide the "foundation on which meaningful cross-cultural comparisons can be built" (l.432), while l.101 says LEVANTE "is not designed to support site-level performance comparisons".
  Reconcile: invariance supports comparing *relations* (for example age slopes) rather than absolute levels.
- The title says "a cross-site comparison", but l.101 says the goal is explicitly not to compare sites. Consider "Measurement invariance and
  angular-disparity effects in mental rotation across three countries".

---

## B. Analysis and reporting

**B1. The Methods and Results descriptions don't match the fitted models.**
- The angle model includes `trial_number * stimulus` and `adaptive * stimulus` terms (`_02` l.66–70), but l.198 and l.254 describe "angle, stimulus type, site, age,
  and all of their possible interactions" only. Describe the covariates, and give the mechanism for including `trial_number` (fatigue/practice).
- l.211 says the sex RT model is "the same angular sensitivity model... with the addition of a sex predictor". `sex_mod` (`_03` l.10) actually drops both
  `trial_number` and `adaptive`, and adds a five-way interaction. Either add the covariates for consistency or describe it accurately.
- l.208 says the ability model has "fixed effects for site", but l.339 and the code (`age * sex * site_label`) include all interactions.
- The Methods should say the first trial is dropped because ____ (l.201 doesn't justify it).

**B2. The sex and ability marginal effects use a balanced grid, contradicting the stated policy.**
l.200 and the Supplement (S2.2) argue that slopes should be averaged over observed trials, because a balanced grid over-weights sparse 3D/young cells.
But the sex RT comparisons and slopes (`_03` l.49–55, l.77–85, l.108–113) use `newdata = sex_pred_grid`, a balanced grid,
and so do the ability contrasts (`ability_grid`, l.243). The sex effect on RT is therefore estimated under the weighting the paper argues against. Switch to observed-data
AMEs, or report both as in Table S3.

**B3. Report CIs and effect sizes.** Every result is given as β, SE and p. Add 95% CIs (APA 7), and give standardised effects for the age and sex results
(the SD-per-year figure is in the text at l.342 but not the Abstract). State units in the Abstract: "β = 0.33 θ units per year".
Also state that the overall angle slope (a trial-weighted average dominated by the larger sites) is not a "typical" site-level slope.

**B4. Multilevel-model reporting.** No convergence or singular-fit information is given for the 4-way-interaction random-slope models. Report it. The full
fixed-effect tables for `full_mod`, `sex_mod` and `ability_sex_mod` should go in the Supplement. The p-values in the slopes table (`tbl-slopes`) involve many comparisons, so say whether any correction is applied.

**B5. CAT robustness checks are weak.**
l.205 offers (i) a weaker accuracy–mean-angle correlation under CAT and (ii) a non-significant angle-slope difference as evidence of no bias.
A non-significant difference isn't evidence of equivalence, and (i) is hard to interpret because CAT is designed to couple ability and angle.
Report the Δβ with a 95% CI and an equivalence bound, and add the most informative sensitivity analysis: refit the angle model on fixed-form runs only (minus uniandes-co-rural), and show the slopes agree.

**B6. Age is modelled as linear.** The θ-vs-age model (l.339) and the angle model assume linearity across 5–13. The GAM figure that
motivated the original text (`fig-ability-age`) is commented out (l.332). Test a quadratic or spline age term and report it, or restore a short descriptive θ-by-age figure.

**B7. Repeated assessments.** 121 children (12%) have two assessments **(checked)**; the paper says "each", which is correct (no child has three after exclusions). Report the 1,037 children / 1,158 assessments split in the Abstract.
Say which unit each analysis uses (θ and RT models at assessment level, abstract at child level).

**B8. Clarify the IRT specification (l.190–192).** State the parameterisation of the priors: is N(0, 3) a variance or an SD, and is it placed on the intercept or on *b*?
Justify fixing guessing at 0.5. Soften "estimates item-level parameters independently of the specific sample tested": that holds only when the model fits.
Report reliability per site as a table, not an inline string, and say what values count as adequate.

**B9. Exclusion and sample reporting.** Report counts by exclusion reason (age, <10 trials, <3 month gap) rather than one aggregate (l.155). Add a sex × site count table to the participant tables.
Check that the quantitative site table's per-site counts (computed from trial data) match `n_final` (computed from IRT scores).

**B10. `fmt_p` (`_00` l.8) drops trailing zeros** (p = .1 prints ".1", p = .0495 prints ".05"). Use `formatC(p, format = "f", digits = 3)` so values print as .100 and .050.

---

## C. Framing, claims and citations

**C1. Unsupported SES statements.** l.150 and l.153 say participants "mainly came from middle- to upper-middle-income backgrounds", yet l.155 says no SES data are available.
Cite the recruitment source, or say "likely".

**C2. The mpieva-de paragraph (l.419) interprets site differences** (higher baseline RT, steeper absolute slopes) as a testing-format effect, which sits oddly with the stated policy of not interpreting site differences (l.101, l.414).
It also contradicts the Results, where site slope differences were "small" (l.264). The claim is about additive slopes, but the main text reports only multiplicative ones. Either cite Table S4 numbers or tone it down to a hypothesis.

**C3. "Western" vs "non-Western" vs income.** The text switches between "Western", "WEIRD", "middle-to-high-income" and "Global South" (l.93, l.411, l.414, l.429). Colombia is called "non-Western" at l.414 but "Global South" elsewhere. Pick one framing (income level + region) and apply it throughout.

**C4. Citation checks (I couldn't verify these without the sources).**
- l.79: `hetland2000learning` is a meta-analysis of music *instruction* improving spatial reasoning, whereas the sentence says spatial ability *predicts* music outcomes. Reverse direction? Confirm or change the verb.
- l.85 vs l.91: `jansen2013mental` is cited for children needing simpler 2D stimuli and also for sex differences on "more demanding cube figure conditions". Check both uses fit.
- l.91: confirm "over 30,000 children aged 3–17" and "g ≈ 0.20 around age 6" against Lauer et al. (2019).
- l.93: `nunez1998mental` "n = 151": confirm.
- About 50 entries in `library_mrot.bib` are never cited in the main text (probably used in the appendix/extra files). Harmless to output, but prune if the bib is shared with the submission.

**C5. Redundancy.** The LEVANTE network expansion (Ghana, India, Peru, Argentina) is described both in the Discussion (l.414) and the Limitations (l.429). The Discussion's opening paragraph (l.411) restates the whole paper before the section-by-section Discussion repeats it. Trim.

**C6. Anonymisation and journal requirements.** The data-sharing statement links an anonymous repo, but `mask: false` (l.28) leaves author names, author-note and funding (Jacobs Foundation) visible. Check the target journal's blinding rules and set `mask: true` for the review copy. Also add consent/assent statements and ethics approval identifiers (or say they are in the LEVANTE protocol paper), since the Ethics section (l.159) describes only what the LDR does.

---

## D. Typos and wording

| Line | Fix |
|---|---|
| 10 | `<hhttps://anonymous.4open.science/...>` has an extra "h". |
| 12 | "The author has no conflict of interest" → "The authors have..." (the paper has several authors). |
| 83 | "The classic mental rotation tasks, first developed by..., presents" → subject–verb agreement ("task... presents" or "tasks... present"). |
| 150 | "Leipzig a mid-sized urban centre" → "Leipzig is a mid-sized...". |
| 153 | "most population metropolitan region" → "most populous". |
| 147 | "Chiquinquira" → "Chiquinquirá". |
| 352 | "This effects holds" → "This effect holds"; "both girls (...) and boys being (...) being about" has doubled "being". |
| 147 | Inline R mixes `` `{r} x` `` and `` `r x` `` in one sentence; use one form. |
| 171 | "the nine core tasks" is stated twice within three sentences. |
| 85–86 | An HTML comment block holds a sentence the text needs (see A7). Restore or delete it. |

---

## E. Code and reproducibility

**E1. The abstract guard (l.443–476) doesn't cover everything typed in the abstract.** It checks the angle, age and sex statistics, N and ΔBIC, but not the sex counts
(411 / 427 / 199, which I verified are correct against the data), the age range, or the 2D/3D claim. Add them.

**E2. Supplement figure numbering may be off.** The example-items chunk is labelled `apx-mrot-example-items`, not `fig-…`, so Quarto won't number it. The main text cites "Figure S1" for the example
items (l.171), S2 for item information, S3/S4 for parameter scatters, S5 for raw RT and S6 for the full-range plot. Rendered numbering would then start one lower (item information = S1). Render the supplement and check, and give every figure
a `fig-` label with `@fig-` cross-references instead of hard-coded "Figure S5" text.

**E3. Hard-coded numbers in `supplementary.qmd`.** "183 trials from 40 children" (l.376), "2.28 times" (l.406), "more than 20 times" and "approximately eight times / one third" (l.273) and "0.14 ... 15%" (l.382) should be computed inline as the rest are, or they will go stale.

**E4. The data pipeline is duplicated.** `supplementary.qmd` l.53–78 re-creates the `rt-angle-data` chunk from `_02`, and the two already differ slightly: the supplement uses `include.lowest = TRUE` for age groups while `_00` uses `FALSE`. Source one shared helper.

**E5. Housekeeping.** `mrot_paper_extra.qmd`, `gender_analysis.Qmd`, `_04_strategies.qmd` and the commented-out appendix include are outside the build chain. Libraries loaded for the dropped strategies analysis (`factoextra`, `umap`, `Rtsne`,
`gridExtra`, `tidytext`) slow rendering and complicate `renv`. Archive or delete what is dead.

---

## What already works well (keep)

- The supplement's weighting analysis (observed trials vs balanced grid) and the log-vs-additive RT analysis with a Jacobian-corrected AIC are unusually transparent.
- The common-angle 2D/3D contrast avoids the unequal-range confound.
- Handling CAT/fixed format as a modelled covariate, and the explicit reason `adaptive × site` can't be estimated, is good practice.
- Stating up front that site-level absolute comparisons aren't intended.

---

## Follow-up analyses (done; see `extra_analyses.qmd`)

Run for A3, A5, A7 and B5. Code: `../03_irt_checks.qmd`, `../helper/irt_checks.R`, `extra_analyses.qmd`.

- **A7 (2D vs 3D):** 3D slope is steeper on the common angles (+0.027, p = .003), but only at mpieva-de (+0.060); about 0 at the other three sites (heterogeneity χ²(6) = 18.1, p = .006). Revise any "holds across sites" wording.
- **A5 (accuracy and guessing):** accuracy falls about 6 points per 40° (2D) and 7 points (3D), at every site. The age gradient in the RT angle slope survives all exclusions (difference 0.060–0.096, all p < .001) but is smallest when only above-chance runs are kept.
- **A3 (dimensionality):** the one-factor model is rejected (ΔBIC ≈ 293–307 against 2-factor or general + 3D-specific). The 2D–3D latent correlation is .42–.75 across datasets.
- **A3 (DIF):** 6 of 12 item classes flag under the one-factor model, but only 2 (2D duck 40°, 3D shape 40°) under the two-factor model. Estimates are unstable in sparse cells.
- **B5 (CAT):** accuracy and RT-slope results are unchanged on fixed-form runs only.

---

## F. Second reviewer's comments: what was new, and what I checked

An external review was compared against sections A–E. Most of its points were already covered (see the cross-reference at the end).
The items below were **not** in the first pass. Where I could test a claim, the result is marked **(checked)**, with the file or run used.
The rest are reported by the reviewer and I have not confirmed them.

### F1. Table 3 (IRT model comparison) is internally inconsistent. **(checked, `models/mrot_anova.rds`)** Highest priority.

| Model | Params | logLik | AIC | BIC |
|---|---|---|---|---|
| 2PL configural | 96 | −21642.6 | 43477.2 | 43987.4 |
| 2PL metric | 60 | −21579.1 | 43278.2 | 43597.1 |
| 2PL scalar | 30 | −21675.7 | 43411.4 | 43570.8 |
| Rasch configural | 52 | −21635.7 | 43375.4 | 43651.8 |

- A nested model cannot have a higher likelihood than the model that contains it. The 2PL configural model is worse than both the 2PL metric model and the Rasch configural model it nests. This points to non-convergence or to priors in the objective.
- The priors do change the likelihood. I refit the scalar model without priors: logLik −21635.9 against −21675.7 with them, a difference of about 40. Penalised likelihoods are therefore not comparable across levels of invariance, and the BIC comparison in Table 3 is not reliable as reported.
- The configural and metric rows have 96 and 60 parameters (12 classes × 2 × 4 groups; 12 + 48), so they do not free the group means and variances, whereas the scalar row (30) does. Check that the three rows are identified the same way.
- AIC prefers **metric** (43278) over scalar (43411). Results l.220 says scalar "provided the best fit (BIC = …, AIC = …)", but its AIC is not the lowest. Say so, or justify choosing BIC over AIC.
- **ΔBIC:** 43987.39 − 43570.82 = 416.57. The Abstract and text give 416 (truncated) and Table 3 gives 417 (rounded). Use one rounded value, and fix the hard-coded `delta_bic = "416"` in the abstract guard (E1).
- Fix: refit with convergence checks (increase `NCYCLES`, report the convergence flag), and report either unpenalised likelihoods or a prior-sensitivity row. State that guessing is fixed, so the "2PL" and "Rasch" models are really 3PL and 1PL with c = .5.
- Rasch reliabilities in `models/mrot_rxx.rds` are 0.31–0.34 per dataset against 0.73–0.89 for the 2PL. They are what the paper reports. The gap is large for the same items and sample, so confirm how `rxx` is computed for the Rasch model.
- I already tested partial invariance and prior-free DIF (A3): under the two-factor model only 2D duck 40° and 3D shape 40° flag. That answers the reviewer's request to free the 3D items, and it can go into the paper.

### F2. The adaptive-format check contradicts Table 4. **(checked, scratch refit of `_02` `full_mod`)**

- Text (l.205): Δβ = 0.011, SE = 0.008, t = 1.3. I reproduced this. It comes from `_00` l.291, which fits `log_rt ~ angle_sc * adaptive` with no stimulus, site or age terms.
- Table 4's TRUE − FALSE row (−0.02, SE 0.005, p < .001) is a contrast of marginal slopes from `full_mod`. That model has no adaptive × angle term, so the contrast reflects which sites, stimuli and ages ran each format, and its SE is not an interaction SE.
- The proper test adds `angle_sc:adaptive` to the full model: **β = −0.019, SE = 0.010, t = −1.93, LRT χ²(1) = 3.68, p = .055**. The adaptive (CAT) slope is flatter. That is borderline rather than "no difference", and it matters because uniandes-co-rural is 100% adaptive and has the flattest slope.
- Fix: report this interaction (with a CI) in the Methods, delete the sentence "does not differ significantly", and either drop the adaptive row from Table 4 or footnote what it contrasts. Combine it with the fixed-form-only refit already in B5.

### F3. Angle function: the text calls it both non-linear and linear. **(partly checked)**

- l.267 says Fig 1 "suggests some non-linearity", then says the 0–360° check supports "the shortest-path recoding and the use of a linear angle term". Fig S6 only tests symmetry about 180°. It says nothing about linearity.
- Pooled raw mean log RT (2D, correct, trial ≥ 2; not participant-adjusted) is not mirror-symmetric:

  | Angle | 20 | 40 | 80 | 120 | 160 | 200 | 240 | 280 | 320 |
  |---|---|---|---|---|---|---|---|---|---|
  | log RT | 0.75 | 0.85 | 0.99 | 1.01 | 1.13 | 1.25 | 1.02 | 0.96 | 0.78 |

  The supplement itself says the peak is at 200°, not 180°. 200° (recoded 160°) is about 0.12 log units slower than 160°, and 320° (recoded 40°) is about 0.08 faster than 40°. The reviewer also says rabbit 80° is slower than 120°. I did not check that.
- Fix: soften "supports shortest-path recoding" to "is broadly consistent with", say which asymmetries remain, and either model the offset or test sensitivity to dropping the 200° and 160° cells. Combine this with the quadratic or factor-coded angle comparison suggested in A6.

### F4. Further wording and analysis points on the angle effect and sex

- **Table 4 headline (extends A7):** it still leads with the full-range 2D vs 3D contrast (Δ = 0.00, p = .906), which the text itself calls an artefact of unequal angle ranges. Lead with the common-angle contrast, and put the 3D weighting sensitivity in the main text. The 3D slope falls from 0.155 to 0.115 under balanced weighting (Table S3), and the observed-trials scheme was chosen after seeing both. My follow-up shows the 3D − 2D difference comes from mpieva-de only.
- **mpieva-de explanation (extends C2):** the Discussion argues the steeper slope follows from slower baselines. A log-RT model already expresses slopes proportionally, so baseline scaling is removed. The steeper *proportional* slope at mpieva-de still needs another explanation, such as format, device timing or age mix. The argument only works for additive slopes.
- **Age × slope and Fig 1 (extends A5, A6):** report slopes by site × age group. Fig 1 shows near-flat 2D functions for 5–8 year-olds at Bogotá and rural, which undercuts "replicates robustly across all four sites" for the youngest children. My guessing sensitivity (`extra_analyses.qmd`) shows the age gradient shrinks but persists when only above-chance runs are kept. The log scale also inflates proportional slopes when intercepts are lower. Say both.
- **Sex (extends A1, A2):** "holds within stimulus type" is overstated, because the 3D contrast has p = .103. State the boys' RT advantage (about 7.4% faster, p = .004) in the Abstract and Lay Summary. The sex subsample's pooled angle slope is 0.13 against 0.16 overall, because it over-represents Colombia. Add sex × site tests and an equivalence bound.

### F5. Reporting errors

- **RMSE in seconds is wrong. (checked, `_02` l.254–255, `_03` l.210–211, `mrot_paper.qmd` l.255, l.350.)** `RMSE_exp = exp(RMSE)` is a multiplicative factor on RT (0.58 log units is a factor of 1.79), not "1.79 seconds". Report "RMSE = 0.58 log units, a typical residual factor of 1.79", and fix the ability-model RMSE sentence (l.340) to say its units.
- **Exclusion counts. (checked, `_00`.)** The 1,251 → 1,037 arithmetic is correct only after accounting for children who kept another assessment. 1,251 children and 1,502 runs were scored. 344 runs from 333 children were excluded, but 119 of those children keep another valid run. So 214 children are lost entirely, and 1,251 − 214 = 1,037. The text prints 333 and 1,037 side by side. Report "344 assessments excluded (from 333 children; 214 lost entirely)" and break it down by reason (B9).
- **Demographics model:** the Methods give sex × age with site as a fixed effect, and the Results say "all possible interactions". See B1. In addition, "β = 0.33 = 0.22 SD/year" implies a θ SD of about 1.5. State the SD used.
- **Income wording (extends C3):** Colombia is classed as an upper-middle-income country (World Bank). "Two low-to-middle-income sites from the Global South" (l.411, l.414, l.432) needs rewording, for example "sites in Colombia (upper-middle-income)". Say what is known about the rural sample.
- **Citation:** `frick2013development` (l.89) is cited for improvement "between ages 3–13 years", but the study covers 3–5-year-olds. Cite the 6–13 evidence separately (`marmor1975development`, `kail1980developmental`) or narrow the claim.

### F6. Figures, tables and typos not in section D

| Location | Fix |
|---|---|
| Fig S5 (`supplementary.qmd` l.518) | The y-axis says "Reaction time (s)" but shows log seconds (−2 to 3). Relabel it and use "response" rather than "reaction" throughout (also `_03` l.170, in a commented-out block). |
| Fig 1 caption | "Points" is used for both group means and individual observations. Name each. |
| Fig S2 caption (l.122) | The source has "(θ)", so the missing symbol is probably a font or render problem. Check the PDF. The claim that higher angles are "more discriminating" is stated for all items. The reviewer says 3D 80° vs 120° does not follow it. Check against the item parameters. |
| Table S1 (`supplementary.qmd` l.248–257, l.285–287) | `age_group` is converted with `as.character()` before `arrange()`, so "11–14" sorts before "5–8". Keep it as a factor. |
| Age labels | Text says "5–7 / 11–13", tables use `[5,8)`, and the supplement says "5–8". Use one scheme. The supplement's `include.lowest = TRUE` also differs from `_00` (see E4). |
| Footnote on sex (l.91) | The footnote marker renders as "sex.147" (reviewer's report). Check the rendered footnote numbering. |

### Cross-reference: reviewer points already covered in sections A–E

Sex missing from Abstract/Discussion (A1); a null sex result as validity evidence (A2); no unidimensionality test (A3); BIC-only invariance (A3); "overlapping items" undefined (A3); 2D vs 3D not posed as an RQ (A7); no accuracy analysis, guessing and the age direction (A5, A6); CAT robustness (B5); "common/universal" (A9); Methods/Results model mismatches (B1); typos at l.10, l.12, l.83, l.150, l.153 and l.352 (D). I have run follow-up analyses for the first four, and for the 2D/3D and accuracy points; see `extra_analyses.qmd`.
