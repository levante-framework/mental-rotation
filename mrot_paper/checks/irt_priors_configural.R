setwd(here::here())
source("helper/irt_checks.R")
dat <- load_mrot_irt_data("models/mrot/multigroup_dataset/overlap_items/mrot_2pl_f1_scalar.rds")
allc <- unique(dat$class)
fits <- list(
 `configural, fixed groups, priors`    = fit_mrot(dat,"uni",allc,priors=TRUE, fix_groups=TRUE, ncycles=6000),
 `configural, fixed groups, no priors` = fit_mrot(dat,"uni",allc,priors=FALSE,fix_groups=TRUE, ncycles=6000),
 `scalar, priors`                      = fit_mrot(dat,"uni",priors=TRUE),
 `scalar, no priors`                   = fit_mrot(dat,"uni",priors=FALSE))
r <- imap(fits, \(m,l) fit_summary(m,l)) |> list_rbind()
print(as.data.frame(r), digits=8)
cn <- fits[[2]]; sn <- fits[[4]]
cat("LRT scalar vs configural, no priors: chisq=", 2*(cn@Fit$logLik - sn@Fit$logLik), "df=", extract.mirt(cn,"nestpars")-extract.mirt(sn,"nestpars"), "\n")
# scalar-model item parameters by class (priors)
est <- as_tibble(mod2values(fits[[3]])) |> filter(name %in% c("a1","d"), str_detect(item,"-1$"), group==levels(dat$group)[1]) |>
  select(item,name,value) |> pivot_wider(names_from=name,values_from=value) |> mutate(b=-d/a1)
print(as.data.frame(est), digits=3)
# configural no-priors params
est2 <- as_tibble(mod2values(cn)) |> filter(name %in% c("a1","d"), str_detect(item,"-1$")) |> select(group,item,name,value) |> pivot_wider(names_from=name,values_from=value) |> mutate(b=-d/a1)
print(as.data.frame(est2), digits=3)
# marginal reliability scalar (priors) per group, 2PL, and Rasch via mirt
for (g in levels(dat$group)) {
  th <- fscores(fits[[3]], method="EAP", full.scores.SE=TRUE)
}
