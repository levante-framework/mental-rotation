source(here::here("mrot_paper/checks/prep.R"))
suppressMessages(library(lme4))
th <- mrot_df |> left_join(sex_data_cleaned, by="user_id")
m3 <- lmer(metric_value ~ age + I(age^2) + site_label + (1|user_id), th, REML=FALSE); print(round(fixef(m3)[1:3],3))
for (a in c(5,7,9,11,13)) cat("age",a,"slope/yr:", round(fixef(m3)["age"] + 2*fixef(m3)["I(age^2)"]*a,3), "\n")
ths <- th |> filter(!is.na(sex))
sdth <- sd(ths$metric_value)
for (s in unique(ths$site_label)) { d <- filter(ths, site_label==s); m <- lm(metric_value ~ age + sex, d); cc <- summary(m)$coefficients; r <- grep("sex", rownames(cc)); cat(s, rownames(cc)[r], "diff in SD:", round(cc[r,1]/sdth,3), "+-", round(1.96*cc[r,2]/sdth,3), "\n") }
# first-run only, to avoid repeat-user issue
