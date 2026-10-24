setwd(here::here())
source("helper/irt_checks.R")
dat <- load_mrot_irt_data("models/mrot/multigroup_dataset/overlap_items/mrot_2pl_f1_scalar.rds")
m2 <- fit_mrot(dat,"uni"); mr <- fit_mrot(dat,"uni",rasch=TRUE)
print(as.data.frame(bind_rows(fit_summary(m2,"2pl scalar"), fit_summary(mr,"rasch scalar"))), digits=8)
for (nm in c("2PL","Rasch")) { m <- list(m2,mr)[[match(nm,c("2PL","Rasch"))]]
  cat(nm, "marginal rxx by group:\n")
  for (g in levels(dat$group)) { mg <- extract.group(m, g); cat("  ", g, round(marginal_rxx(mg),3), "\n") }
  print(round(sapply(levels(dat$group), \(g) { p <- coef(m, simplify=TRUE)[[g]]$cov; p[1,1] }),3)) }
print(round(coef(mr, simplify=TRUE)[[1]]$means,2)); 
