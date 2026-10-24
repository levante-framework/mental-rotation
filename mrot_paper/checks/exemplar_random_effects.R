source(here::here("mrot_paper/checks/prep.R"))
suppressMessages({library(lme4); library(marginaleffects)})
deg <- 40; yrs <- 2
dd <- mrot_rt_trial |> filter(correct==1, trial_number!=1) |>
  mutate(item_group=factor(item_group), stimulus=factor(stimulus), site_label=factor(site_label),
         angle_sc=(angle-mean(angle))/deg, adaptive=factor(adaptive), age_sc=(age-mean(age))/yrs)
contrasts(dd$site_label) <- contr.sum(levels(dd$site_label)); contrasts(dd$stimulus) <- contr.sum(levels(dd$stimulus))
for (v in c("item_uid","item","item_original")) cat(v, n_distinct(dd[[v]]), "\n")
print(head(dd |> distinct(item_uid, item, item_original), 8))
ex <- intersect("item", names(dd))
f0 <- log_rt ~ angle_sc * stimulus * site_label * age_sc + trial_number * stimulus + adaptive * stimulus + (1 + angle_sc | user_id)
m0 <- lmer(f0, dd, REML=FALSE, control=lmerControl(optimizer="bobyqa"))
dd$inst <- dd$item_original; cat("instances:", n_distinct(dd$inst), "\n"); m1b <- update(m0, . ~ . + (1 | item) + (1 | inst)); print(anova(m0, m1b)); print(VarCorr(m1b)); s2 <- slopes(m1b, newdata=dd, re.form=NA, variables="angle_sc", by="item_group"); print(as_tibble(s2) |> select(item_group, estimate, std.error, p.value))
m1 <- update(m0, . ~ . + (1 | inst))
print(anova(m0, m1)); print(VarCorr(m1))
s1 <- slopes(m1, newdata=dd, re.form=NA, variables="angle_sc", by="item_group"); print(as_tibble(s1) |> select(item_group, estimate, std.error, p.value))
