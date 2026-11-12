# Fit the diffusion IRT model to the mental rotation data.
#   Rscript --vanilla diffirt/02_fit_diffirt.R [model=Q] [n_persons=all] [lib=fast|orig] [nq=7] [se=FALSE] [ter=class|group|one[:<start s>]|fixed:<s>]
# lib=fast uses the optimised local diffIRT (installed in ~/Library/R/diffirt-fast, built from
# ~/Documents/GitHub/diffIRT, branch fast-kernel); lib=orig the original commit 1fdcda4 (installed in
# ~/Library/R/diffirt-orig). Note that the default library's diffIRT is also the optimised build.
suppressMessages({library(dplyr); library(readr); library(here)})
args <- commandArgs(TRUE)
arg <- \(i, default) if (length(args) >= i && args[i] != "NA") args[i] else default
model <- arg(1, "Q"); n_use <- arg(2, "all"); lib <- arg(3, "fast"); nq <- as.integer(strsplit(arg(4, "7"), ",")[[1]]); se <- as.logical(arg(5, "FALSE")); ter_mode <- arg(6, "class")  # Ter: per class | per 2D/3D | one value | fixed:<s>
if (lib %in% c("fast", "orig")) .libPaths(c(path.expand(paste0("~/Library/R/diffirt-", lib)), .libPaths()))
suppressMessages(library(diffIRT))
cat("diffIRT from", find.package("diffIRT"), "\n")

mats <- Sys.getenv("DIFFIRT_MATS", "diffirt_mats")   # e.g. diffirt_mats_rtmin0.5
m <- read_rds(here("data", paste0(mats, ".rds")))
rt <- m$rt; x <- m$x
if (n_use != "all") { set.seed(1); keep <- sort(sample(nrow(rt), as.integer(n_use))); rt <- rt[keep, ]; x <- x[keep, ] }
used <- colSums(!is.na(rt)) > 0
rt <- rt[, used]; x <- x[, used]; cls <- m$cols$item_uid[used]
nit <- ncol(rt); cat("persons:", nrow(rt), " items:", nit, " model:", model, " nq:", paste(nq, collapse = ","), "\n")

# parameters shared across the columns of an item class: a_i, v_i, Ter_i (3 x classes) + 2 scale parameters
k <- as.integer(factor(cls)); nc <- max(k)
# ter: "class" | "group" (2D/3D) | "one", each optionally followed by ":<s>" to start Ter there instead of at the
# EZ-diffusion value (e.g. "one:0.3"), or "fixed:<s>" to fix Ter at <s> seconds
start <- NULL
tm <- strsplit(ter_mode, ":")[[1]]
if (tm[1] == "fixed") {   # non-decision time fixed (0 in constrain; value in start)
  constrain <- c(k, nc + k, rep(0L, nit), 2 * nc + 1, 2 * nc + 2)
  start <- c(rep(NA, 2 * nit), rep(as.numeric(tm[2]), nit), NA, NA)
} else {
  kt <- switch(tm[1], class = k, group = as.integer(factor(grepl("_3d_", cls))), one = rep(1L, nit))
  nt <- max(kt)
  constrain <- c(k, nc + k, 2 * nc + kt, 2 * nc + nt + 1, 2 * nc + nt + 2)
  if (length(tm) > 1) start <- c(rep(NA, 2 * nit), rep(as.numeric(tm[2]), nit), NA, NA)
}

t <- system.time(fit <- diffIRT(rt, x, model = model, constrain = constrain, start = start, se = se,
                                control = list(nq = nq, trace = 0)))
cat("elapsed (s):", round(t[["elapsed"]], 1), " conv:", fit$conv, " -2LL:", round(fit$totLL, 1),
    " npars:", fit$npars, " failed subjects:", fit$nr_fail, "\n")
out <- list(fit = fit, classes = levels(factor(cls)), constrain = constrain, time = t, n = nrow(rt), lib = lib)
tag <- sprintf("%s%s_%s_n%s_nq%s%s%s", tolower(model), sub("^diffirt_mats", "", mats), lib, n_use, paste(nq, collapse = "-"), if (se) "_se" else "", if (ter_mode == "class") "" else paste0("_ter", sub(":", "", ter_mode)))
write_rds(out, here("models", paste0("diffirt_", tag, ".rds")), compress = "gz")
nc <- max(k); p <- fit$par
print(data.frame(class = levels(factor(cls)), a = round(p[match(1:nc, k)], 3),
                 v = round(p[nit + match(1:nc, k)], 3), ter = round(p[2 * nit + match(1:nc, k)], 3)))
cat("scale parameters (omega_gamma, omega_theta):", round(tail(p, 2), 3), "\n")
