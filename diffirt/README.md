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
3. `03_diffirt_checks.R` estimates person parameters with `factest` and compares them with the paper's 2PL scores.

## Results

See the summary in the session notes; models and scores are saved in `models/diffirt_*.rds`.
