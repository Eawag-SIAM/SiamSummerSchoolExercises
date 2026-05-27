from pathlib import Path
import os

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.special import gammaln

from simulated_annealing_abc import (
    DifferentialEvolution,
    SABCConfig,
    make_f_dist,
    sabc,
)

SEED = 20260525
N_INDIVIDUALS = 100
N_PARTICLES = 2000

obs = pd.read_csv( "data/model_survival.csv", sep=r"\s+")
times = obs["time"].to_numpy(dtype=float)
deaths_obs = obs["deaths"].to_numpy(dtype=int)


class Prior:
    def __init__(self, lower: float = 0.01, upper: float = 0.6):
        self.lower = lower
        self.upper = upper

    def rvs(self, rng: np.random.Generator, size: int = 1) -> np.ndarray:
        return rng.uniform(self.lower, self.upper, size=(size, 1))

    def logpdf(self, theta: np.ndarray) -> np.ndarray:
        theta = np.atleast_2d(theta)
        lam = theta[:, 0]
        in_bounds = (self.lower <= lam) & (lam <= self.upper)
        lp = np.full(theta.shape[0], -np.inf)
        lp[in_bounds] = -np.log(self.upper - self.lower)
        return lp


prior = Prior()


def death_probabilities(lam: np.ndarray) -> np.ndarray:
    lam = np.asarray(lam, dtype=float).reshape(-1, 1)
    survival = np.exp(-lam * times.reshape(1, -1))
    survival = np.column_stack([np.ones(lam.shape[0]), survival, np.zeros(lam.shape[0])])
    return -np.diff(survival, axis=1)


def simulator(theta: np.ndarray, y: np.ndarray, rng: np.random.Generator) -> None:
    probs = death_probabilities(theta[:, 0])
    for i, p in enumerate(probs):
        y[i, :] = rng.multinomial(N_INDIVIDUALS, p)[:-1]


def raw_stats(y: np.ndarray, ss_out: np.ndarray) -> None:
    ss_out[:, :] = y


def sufficient_stats(y: np.ndarray, ss_out: np.ndarray) -> None:
    weights = np.arange(1, y.shape[1] + 1)
    ss_out[:, 0] = np.sum(y, axis=1)
    ss_out[:, 1] = y @ weights


ss_obs_raw = deaths_obs.astype(float)
ss_obs_suff = np.array([np.sum(deaths_obs), deaths_obs @ np.arange(1, len(deaths_obs) + 1)])

f_dist_raw = make_f_dist(
    n_samples=len(deaths_obs),
    ss_obs=ss_obs_raw,
    simulator=simulator,
    stats_fn=raw_stats,
    seed=123,
    distance="abs",
)

f_dist_suff = make_f_dist(
    n_samples=len(deaths_obs),
    ss_obs=ss_obs_suff,
    simulator=simulator,
    stats_fn=sufficient_stats,
    seed=456,
    distance="abs",
)

raw_config = SABCConfig(
    f_dist=f_dist_raw,
    prior=prior,
    n_particles=N_PARTICLES,
    v=1.2,
    algorithm="single_eps",
    proposal=DifferentialEvolution(n_para=1, rng=np.random.default_rng(22)),
    rng=np.random.default_rng(18),
    show_checkpoint=100,
)

suff_config = SABCConfig(
    f_dist=f_dist_suff,
    prior=prior,
    n_particles=N_PARTICLES,
    v=1.2,
    algorithm="single_eps",
    proposal=DifferentialEvolution(n_para=1, rng=np.random.default_rng(23)),
    rng=np.random.default_rng(19),
    show_checkpoint=100,
)

print("Running Python SABC without summary statistics...")
raw_result = sabc(raw_config, n_simulation=1_000_000)

print("Running Python SABC with sufficient summary statistics...")
suff_result = sabc(suff_config, n_simulation=1_000_000)


def multinomial_logpmf(y: np.ndarray, p: np.ndarray) -> float:
    return float(
        gammaln(N_INDIVIDUALS + 1)
        - np.sum(gammaln(y + 1))
        + np.sum(y * np.log(p))
    )


def logposterior(lam: float) -> float:
    if not (prior.lower <= lam <= prior.upper):
        return -np.inf
    probs = death_probabilities(np.array([lam]))[0]
    y = np.append(deaths_obs, N_INDIVIDUALS - np.sum(deaths_obs))
    return multinomial_logpmf(y, probs) - np.log(prior.upper - prior.lower)


def run_metropolis(
    start: float = 0.3,
    proposal_sd: float = 0.01,
    n_iter: int = 20_000,
    burn_in: int = 2_000,
    seed: int = SEED,
) -> np.ndarray:
    rng = np.random.default_rng(seed)
    chain = np.empty(n_iter)
    current = start
    current_lp = logposterior(current)
    for i in range(n_iter):
        proposed = current + rng.normal(0.0, proposal_sd)
        proposed_lp = logposterior(proposed)
        if np.log(rng.uniform()) < proposed_lp - current_lp:
            current = proposed
            current_lp = proposed_lp
        chain[i] = current
    return chain[burn_in:]


reference = run_metropolis()
raw_pop = raw_result.population[:, 0]
suff_pop = suff_result.population[:, 0]

plt.figure(figsize=(9, 6))
for sample, label, color, linewidth in [
    (reference, "Reference MCMC", "black", 2.5),
    (raw_pop, "ABC raw data", "#1f77b4", 1.8),
    (suff_pop, "ABC sufficient summary", "#2ca02c", 1.8),
]:
    density = np.histogram(sample, bins=30, density=True)
    centers = 0.5 * (density[1][1:] + density[1][:-1])
    plt.plot(centers, density[0], label=label, color=color, linewidth=linewidth)

plt.xlabel("lambda")
plt.ylabel("Density")
plt.title("Python: ABC posterior comparison")
plt.legend(frameon=False)
plt.tight_layout()
plt.savefig("outputs_exercise5_N100/exercise_5_python_posterior.png", dpi=150)

print("Reference median:", np.median(reference))
print("Raw ABC median:", np.median(raw_pop))
print("Sufficient ABC median:", np.median(suff_pop))
