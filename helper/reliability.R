# Marginal reliability evaluated against the model's own latent distribution.
#
# mirt::marginal_rxx integrates TI / (TI + var_theta). Marginal reliability is
# true variance over true plus error variance, and with a conditional error
# variance of 1 / TI that is v * TI / (v * TI + 1), equivalently TI / (TI + 1/v).
# The default therefore uses v where it needs 1/v. The two agree exactly when
# v = 1 and diverge otherwise, so the default understates reliability for any
# group whose latent variance is estimated freely. The effect is largest for the
# Rasch model, where fixing every discrimination at 1 stretches the latent scale
# to a variance of about 6 and the reported reliability falls to about 0.3.
#
# Passing mean and sd through to marginal_rxx does not fix this. Those arguments
# change only the density integrated against, not the ratio, so they move the
# answer without correcting it.
#
# A limiting case shows which form is right. Holding test information fixed and
# letting the true-score variance grow, reliability must approach 1, since the
# measurement error becomes negligible beside the real variation. v * TI / (v * TI + 1)
# does that; TI / (TI + v) approaches 0.
marginal_rxx_fitted <- function(group_model) {
  cfs <- coef(group_model, simplify = TRUE)
  v  <- as.vector(cfs$cov)[1]
  mu <- as.vector(cfs$means)[1]
  integrand <- function(theta) {
    ti <- testinfo(group_model, matrix(theta))
    v * ti / (v * ti + 1) * dnorm(theta, mu, sqrt(v))
  }
  integrate(integrand, mu - 8 * sqrt(v), mu + 8 * sqrt(v))$value
}
