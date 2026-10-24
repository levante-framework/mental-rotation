# Prep for exploratory runs: purl _00 and the data chunk of _02, minus plot_settings
suppressMessages({library(tidyverse); library(here); library(glue); library(lubridate)})
setwd(here::here())
tf <- tempfile(fileext=".R")
knitr::purl("mrot_paper/_00_data_prep.qmd", output = tf, quiet = TRUE)
code <- readLines(tf)
code <- code[!grepl("plot_settings", code)]
code <- sub("^\\.scale_colour_site <-.*", "", code)
code <- sub("^site_pal <- .*", "", code)
eval(parse(text = code))
tf2 <- tempfile(fileext=".R")
knitr::purl("mrot_paper/_02_angle_sensitivity.qmd", output = tf2, quiet = TRUE)
c2 <- readLines(tf2)
# keep only the first chunk (rt-angle-data)
end <- grep("^## ---", c2)[2] - 1
eval(parse(text = c2[1:end]))
cat("mrot_lme_data rows:", nrow(mrot_lme_data), " users:", n_distinct(mrot_lme_data$user_id), "\n")
