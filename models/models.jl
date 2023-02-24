## -------------------------------------------------------
##
## Defines Example models for the
## Eawag Summer School in Environmental Systems Analysis
##
## -------------------------------------------------------


using DifferentialEquations

using ComponentArrays           # for parameter handling
using UnPack                    #  ""

using DataFrames

"""
# Monod model

## argments

 * `C`: vector of concentrations
 * `par`:  `ComponentVector` containing the following parameters:

    - `r_max`: maximum growth rate
    - `K`: half-saturation concentration

## value
A vector of growth rates

## model

Growth rate `r` is a function of substrate concentration `C`:
```
r = r_max*C / (K + C)
```

## example

```Julia
using ComponentArrays

par = ComponentVector(r_max = 4, K = 3)
C = 0:0.5:10
model_monod(C, par)
```
"""
function model_monod(C::AbstractVector, par::ComponentVector)
    @unpack r_max, K = par
    (r_max .* C) ./ (K .+ C)
end



""""
# Growth model

```
model_growth(times::AbstractVector, par::ComponentArray)
```

## argments

 * `times`: vector of time points to evalute the ODE
 * `par`:  `ComponentVector` containing the following parameters:

    - `mu`       maximum growth rate of microorganisms
    - `K`        half-concentration of growth rate with respect to substrate
    - `b`        rate of death and respiration processes of microorganisms
    - `Y`        yield of growth process
    - `inits`   named tuple of initial concentrations for `C_M` and `C_S`


## value

A data frame containing `C_M` and `C_S` for all points in `time`.

## model
  growth of microorganisms on a substrate in a batch reactor:

```
  dC_M         C_S
  ----  =  mu ----- C_M  -  b C_M
   dt         K+C_S

  dC_S      mu   C_S
  ----  = - --  ----- C_M
   dt       Y   K+C_S
```
state variables:

  - C_M      concentration of microorganisms in the reactor
  - C_S      concentration of substrate in the reactor


## example

```Julia
using ComponentArrays
using Plots

# set parameters
par = ComponentVector(mu=4, K=10, b=1, Y=0.6,
                      inits = (C_M=10.0, C_S=50.0))

# run model
res1 = model_growth(0:0.01:3, par)

# plot results
plot(res1.time, res1.C_M,
     label = "C_M",
     xlabel = "time",
     ylabel = "concentrations",
     title = "Deterministic model growth")
plot!(res1.time, res1.C_S, label="C_S")

```
"""
function model_growth(times::AbstractVector, par::ComponentArray)

    # define the RHS of the ODE system
    function growth!(du, u, p, t)
        @unpack mu, K, b, Y = p
        du[1] = mu * (u[2]/(K + u[2])) * u[1] - b*u[1]
        du[2] = (-mu/Y) * (u[2] / (K + u[2])) * u[1]
    end

    # solving ODE
    u0 = par.inits
    tspan = extrema(times)
    prob = ODEProblem(growth!, u0, tspan, par)
    sol = solve(prob, Tsit5())

    # return result as DataFrame
    res = DataFrame(sol(times))
    rename!(res, [:time, :C_M, :C_S])

    return res

end
