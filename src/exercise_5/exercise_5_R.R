set.seed(20260525)

suppressPackageStartupMessages({
  library(EasyABC)
  library(FME)
})


obs <- read.table(file.path("data/model_survival.csv"), header = TRUE)

d.prior <- function(par) dunif(par, min = 0.01, max = 0.6)
r.prior <- function() runif(1, min = 0.01, max = 0.6)

survival.sampler <- function(par, t = obs$time, N = 100) {
  if (par < 0) return(rep(0, length(t)))
  S <- exp(-par * c(0, t))
  S <- c(S, 0)
  p <- -diff(S)
  y <- rmultinom(1, N, p)[-(length(t) + 1)]
  return(y)
}

f.dist <- function(par) {
  sum(abs(survival.sampler(par) - obs$deaths))
}

SABC.res <- SABC(
  r.model = f.dist,
  r.prior = r.prior,
  d.prior = d.prior,
  n.sample = 2000,
  eps.init = 20,
  iter.max = 1000000,
  v = 1.2,
  beta = 0.8
)

f.summarystats <- function(y) y

SABC.SS.res <- SABC(
  r.model = survival.sampler,
  r.prior = r.prior,
  d.prior = d.prior,
  n.sample = 2000,
  eps.init = 20,
  iter.max = 1000000,
  summarystats = TRUE,
  y = obs$deaths,
  f.summarystats = f.summarystats,
  v = 1.2,
  beta = 0.8
)

ss <- function(y) {
  c(sum(y), sum(y * seq(1, length(y))))
}

f.dist <- function(par) {
  sum(abs(ss(survival.sampler(par)) - ss(obs$deaths)))
}

SABC.suff.res <- SABC(
  r.model = f.dist,
  r.prior = r.prior,
  d.prior = d.prior,
  n.sample = 2000,
  eps.init = 20,
  iter.max = 1000000,
  v = 1.2,
  beta = 0.8
)

logposterior <- function(y, N = 100, t, par) {
  log.prior <- log(d.prior(par))
  if (!is.finite(log.prior)) return(-Inf)
  S <- exp(-par * c(0, t))
  S <- c(S, 0)
  p <- -diff(S)
  y <- c(y, N - sum(y))
  LL <- dmultinom(y, prob = p, log = TRUE)
  return(LL + log.prior)
}

obj.funct <- function(par, y, t) {
  -2 * logposterior(y, N = 100, t = t, par = par)
}

AMDR <- modMCMC(
  f = obj.funct,
  p = c(lambda = 0.5),
  jump = 0.01,
  niter = 10000,
  updatecov = 10,
  covscale = 2.4^2,
  ntrydr = 3,
  y = obs$deaths,
  t = obs$time
)

AMDR.chain <- AMDR$pars[-(1:1000), ]

png(file.path("outputs_exercise5_N100/exercise_5_R_posterior.png"), width = 1400, height = 900, res = 150)
plot(density(AMDR.chain), xlab = expression(lambda), main = "R: ABC posterior comparison",
     lwd = 3, col = "black")
lines(density(SABC.res$E[, 1]), col = "#1f77b4", lwd = 2)
lines(density(SABC.SS.res$E[, 1]), col = "#d62728", lwd = 2)
lines(density(SABC.suff.res$E[, 1]), col = "#2ca02c", lwd = 2)
legend("topright",
       legend = c("Reference MCMC", "ABC raw data",
                  "ABC semi-automatic summary", "ABC sufficient summary"),
       col = c("black", "#1f77b4", "#d62728", "#2ca02c"),
       lwd = c(3, 2, 2, 2),
       bty = "n")
dev.off()

cat("Wrote", file.path(out_dir, "exercise_5_R_posterior.png"), "\n")
