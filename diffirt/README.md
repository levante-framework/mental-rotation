# Diffusion IRT on the mental rotation data

Fits the Q-diffusion IRT model (Molenaar, Tuerlinckx & van der Maas, 2015) to the trial-level accuracy and response times,
using the optimised local `diffIRT` (`~/Documents/GitHub/diffIRT`, branch `fast-kernel`).

## Setup

The optimised package is installed in its own library so it does not replace other installs:

```bash
rsync -a --exclude='.git' --exclude='*.o' --exclude='*.so' ~/Documents/GitHub/diffIRT/ /tmp/diffirt_src/
mkdir -p ~/Library/R/diffirt-fast && R CMD INSTALL --library=$HOME/Library/R/diffirt-fast /tmp/diffirt_src
```

The original code (commit `1fdcda4`) can be installed the same way into `~/Library/R/diffirt-orig`. Note that the diffIRT in the
default R library is also the optimised build (it exports `FACscore`), so it cannot serve as the baseline.
The build used OpenMP (Homebrew `libomp`).

## Scripts

1. `01_prepare_data.R [rt_min]` builds person x item matrices (`data/diffirt_mats*.rds`): persons are the 1,158 assessments, columns are
   stimulus x occurrence within the run (81 columns, as in the paper's `all_items` IRT models), cells are accuracy and RT in seconds. Trials with
   RT < `rt_min` (default 0.25 s) or at the 30 s time limit are dropped.
2. `02_fit_diffirt.R model n lib nq se ter` fits the model. Slope (`a`), drift (`v`) and non-decision time (`Ter`) are shared across the columns of an
   item class (stimulus x angle, 12 classes), as in the paper's IRT models. Set `DIFFIRT_MATS` to use a different matrix file.
3. `03_diffirt_checks.R` scores persons from a fit with `factest` and compares them with the paper's 2PL scores. `04_diffirt_summary.R` tabulates the preferred fit (item-class parameters with SEs) and saves its scores.

## Results

Timing (1,158 assessments, 81 columns, Q model): 3 s at 7 quadrature points, 19 s for 7, 15, 25. The original package did not finish a 70-person subset in 20 minutes
(0.7 s with the optimised build).

**Ter.** With the default EZ-diffusion start, several item classes ended with Ter = 0. This was a local optimum, not a feature of the data:

- Raising the fast-response cutoff does not fix it properly. With cutoffs of 1.5, 2 and 3 s, Ter rises to about 1.1, 1.5 and 2.3 s, tracking the cutoff (about 0.7 s below it), because the model is fitting the truncated left edge of the RT distribution. Do not use such cutoffs.
- Starting Ter at 0.3 s instead gives a better fit than any default-start run. At a 0.5 s cutoff, free per-class Ter has -2LL = 253,147 (38 parameters), against 254,121 from the default start. Fixing Ter at 0.1, 0.2, 0.3 and 0.4 s gives -2LL = 255,243, 254,238, 253,789 and 254,651, so the profile is minimised near 0.3 s.
- Per-class Ter is about 0.33-0.39 s for 2D classes and 0.07-0.22 s for the 3D classes, whose RTs are so long that Ter is poorly determined.

Preferred model: cutoff 0.5 s (1.3% of trials dropped), Ter shared within 2D and within 3D and started at 0.3 s, nq = 7, 15. -2LL = 253,385 with 28 parameters.
2D Ter = 0.354 s (SE 0.003), 3D Ter = 0.155 s (SE 0.015). Item drift `v` rises with angle within each stimulus and is far larger for the 3D classes
(1.2-3.4 for 2D, 5.8-11.5 for 3D), matching the difficulty ordering of the paper's IRT models. Standard errors now work (`models/diffirt_item_params.rds`). They come from the
numerical Hessian at 15 quadrature points and are probably optimistic.

Person drift (`theta`) correlates .87 with the paper's 2PL scores (Spearman) and .43 with age. Boundary separation (`gamma`) is unrelated to age (.02).
