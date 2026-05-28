import Pkg

project_dir = normpath(joinpath(@__DIR__, ".."))
Pkg.activate(project_dir)
Pkg.instantiate()

using Random
using SimulatedAnnealingABC
using Distributions
using CSV
using DataFrames
using AdaptiveMCMC
using MCMCChains

ENV["GKSwstype"] = "100"
using Plots
using StatsPlots


Random.seed!(20260525)

repo_dir = normpath(joinpath(@__DIR__, "../.."))
out_dir = joinpath(repo_dir, "outputs_exercise5_N100")
mkpath(out_dir)

obs = CSV.read(joinpath(repo_dir, "data/model_survival.csv"), DataFrame)

prior = Uniform(0.01, 0.6)
d_prior(x) = pdf(prior, x)
r_prior() = rand(prior)

function survival_sampler(λ; N=100, t=obs.time)
    S = exp.(-λ .* t)
    S = [1; S; 0]
    p = -diff(S)
    rand(Multinomial(N, p))[1:(end-1)]
end

f_dist(par, obs) = Float64.(abs.(survival_sampler(par) .- obs.deaths))

sabc_res = sabc(f_dist, prior, obs;
                n_simulation = 1_000_000,
                n_particles = 2000)

ss(y) = (sum(y), sum(y .* (1:length(y))))
f_dist_suff(par, obs) = Float64.(abs.(ss(survival_sampler(par)) .- ss(obs.deaths)))

sabc_suff_res = sabc(f_dist_suff, prior, obs;
                     n_simulation = 1_000_000,
                     n_particles = 2000)

function loglikelihood_survival(N::Int, t, y, λ)
    S = exp.(-λ .* t)
    S = [1; S; 0]
    p = -diff(S)
    y = [y; N - sum(y)]
    logpdf(Multinomial(N, p), y)
end

function logposterior(par)
    ll = logpdf(prior, par[1])
    if isfinite(ll)
        ll += loglikelihood_survival(100, obs.time, obs.deaths, par[1])
    end
    ll
end

mcmc_res = adaptive_rwm([0.3], logposterior,
                        10_000;
                        algorithm = :ram,
                        b = 1000)

reference = vec(mcmc_res.X')
raw_pop = vec(sabc_res.population)
suff_pop = vec(sabc_suff_res.population)

plt = StatsPlots.density(reference, label = "Reference MCMC", xlab = "lambda",
                         title = "Julia: ABC posterior comparison",
                         linewidth = 3, color = :black)
StatsPlots.density!(plt, raw_pop, label = "ABC raw data", linewidth = 2)
StatsPlots.density!(plt, suff_pop, label = "ABC sufficient summary", linewidth = 2)
savefig(plt, joinpath(out_dir, "exercise_5_julia_posterior.png"))

println("Wrote ", joinpath(out_dir, "exercise_5_julia_posterior.png"))
println("Reference median: ", median(reference))
println("Raw ABC median: ", median(raw_pop))
println("Sufficient ABC median: ", median(suff_pop))
