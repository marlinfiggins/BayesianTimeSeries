# Bayesian Time Series Models

Slowly building out methods for doing hierarchical Bayesian inference and prediction for time series data. As it stands, this project is mostly borrowing from [TimeSeers](https://github.com/MBrouns/timeseers) in Python and Facebook's prophet.

## Features

Define a time series model as a sum or product of individual components. For example, we may wish to decompose a time series as a piecewise linear trend plus seasonality (in terms of a Fourier series). For a given number of change-points and Fourier modes, we can define for our model as 

```julia
model = LinearTrend(n_change_points) + FourierSeasonality(n_F_nodes)
```
For trend models with change points, we can additionally specific where these change points are located. When passed with parameters, these models are able to evaluated directly over a time horizon

```
X = model(theta, times)
```

Given time series values `data` and time values `time`, we can then sample from the posterior distribution of the above model given our data as follows using [Stan]().

```julia
samples, cnames = sample_stan(model, times, data;  num_samples)
```

TODO: Instructions for sampling from the chain and doing posterior predictive analysis. Then add forecasting.
TODO: The current methods for this are get_beta()

### Time Series Nodes

This package is built on the idea of decomposing time series in terms of time series nodes. We define several types of time series nodes. By combining individual time series nodes using addition, one can model a time series as a combination of various components defined as trends, seasonality, or other.

### Current Components

Currently, we have implemented several components:

<!--- Make sure this works for single liner trend --->
A piecewise linear trend model parameterized by the number of change points. This model takes in slopes for each of the `n_change_points` change points which will evenly space the change points between 0 and `max_T`.
```julia
LinearTrend(n_change_points, max_T)
```

Alternatively, we can directly pass the change points to the model component as a vector `s`

```julia
LinearTrend(s)
```

Similarly, we include components for piecewise constant trends `ConstantTrend` and a `FlatTrend`. Note that the Linear and Constant trends start at 0, so in order to have a non-zero starting position you must use both `FlatTrend` and `ConstantTrend`.

A seasonality component built from Fourier series which is parameterized by the number of Fourier nodes and the seasonality's period

```julia
FourierSeasonality(n_F_nodes, period)
```
You can also specify additional regressors in the form of

```
AdditionalRegressor(regressors) 
```
where regressors is a 2-D array with each column being a separate component.

### Least Squares

If you're not feeling particularly Bayesian, this package also has support for simple least squares solutions which can be found by doing the following


<!--- How do I want least squares to look?--->

```
X = get_design(model, time)
beta  = X \ data
Y_hat = X * beta
```

#### Planned Components

<!--- This defined radial basis function which repeat every `period` and have `n_nodes` evenly spaced components -->
- `RadialBasisSeasonality(n_nodes, period)`
- `HolidayEffect(days_of_year)`


### To do

- Implement pooling and partial pooling for joint inference of time series
- Implement `RadialBasisSeasonality`
-[x] Work on a method for inference using [Stan](https://github.com/stan-dev/stan) and [CmdStan.jl](https://github.com/StanJulia/CmdStan.jl)
- Work on a method for inference using [AdvancedHMC.jl](https://github.com/TuringLang/AdvancedHMC.jl)
- Add explicit support for lack of `times` and `Vector(Date)`.
-[x] Add support for least squares fit using `\`.
