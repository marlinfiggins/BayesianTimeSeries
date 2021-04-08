# Bayesian_Time_Series

Test project for fun. Slowly building out methods for doing Bayesian estimation of time series data. As it stands, this project is mostly borrowing from [TimeSeers](https://github.com/MBrouns/timeseers) in Python.

## Features

Define a time series model as a sum or product of individual components. For example, we may wish to decompose a time series as a piecewise linear trend plus seasonality (in terms of a Fourier series). For a given number of change-points and Fourier modes, we can define for our model as 

```julia
model = LinearTrend(n_change_points) + FourierSeasonality(n_F_nodes)
```

When passed with parameters, these models are able to evaluated directly over a time horizon

```
X = model(theta, times)
```

Given time series data `data`, we can then sample from the posterior distribution of the above model given our data as follows using [Turing.jl](https://github.com/TuringLang/Turing.jl)

```julia
chain = sample_turing(model, times, data;  num_samples, sampler)
```

Further, we can also sample from the resulting MCMC chain using
```julia
sample_chain(chain, num_samples) 
```

There is also support for sampling directly from the predictive distribution of the chain with
```julia
sample_predictive(new_TS, times, chain, num_samples)
```

### Time Series Nodes

This package is built on the idea of decomposing time series in terms of time series nodes. We define several types of time series nodes. By combining individual time series nodes using multiplication, one can model a time series data as a combination of various components.

### Current Components

Currently, we have implemented several components:

<!--- Make sure this works for single liner trend --->
A piecewise linear trend model parameterized by the number of change points. This model takes in slopes for each of the `n_change_points` change points and an intercept term.

```julia
LinearTrend(n_change_points)
```

A seasonality component built from Fourier series which is parameterized by the number of Fourier nodes and the seasonality's period

```julia
FourierSeasonality(n_F_nodes, period)
```

#### Planned Components

<!--- This defined radial basis function which repeat every `period` and have `n_nodes` evenly spaced components -->
- `RadialBasisSeasonality(n_nodes, period)`
- `HolidayEffect(days_of_year)`


### To do

- Implement pooling and partial pooling for joint inference of time series
- Implement `RadialBasisSeasonality`
- Work on a method for inference using [Stan](https://github.com/stan-dev/stan) and [CmdStan.jl](https://github.com/StanJulia/CmdStan.jl)
- Work on a method for inference using [AdvancedHMC.jl](https://github.com/TuringLang/AdvancedHMC.jl)
- Add explicit support for lack of `times` and `Vector(Date)`.
- Add support for least squares fit using `\`.
