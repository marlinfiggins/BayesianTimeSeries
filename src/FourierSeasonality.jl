
struct FourierSeasonality{T, V} <: TimeSeriesNode where {T <: Int, V <: Real}
    F_Nodes::T
    Period::V
end

function FourierSeasonality(Nodes::T, Period::V) where {T<: Int, V <: Real}
    return FourierSeasonality{T, V}(Nodes, Period)
end

params(TS::FourierSeasonality) = (TS.F_Nodes, TS.Period)
params_shape(TS::FourierSeasonality) = (TS.F_Nodes, 2)
get_components(TS::FourierSeasonality) = TS
get_priors(TS::FourierSeasonality) = fill(Distributions.Normal(0.0, 10.0), params_shape(TS)) # for each index 

function (TS::FourierSeasonality{T,V})(β, t)  where {T <: Int, V <: Real}
    N = TS.F_Nodes
    trig_args = hcat([2*π* n * t / TS.Period for n in 1:TS.F_Nodes]...)

    return sum( (β[:,1]' .* cos.(trig_args)) + (β[:,2]' .* sin.(trig_args)), dims = 2)
end
## On a sum, we'll recursively call for parameters / params size
## THis will allow us to set priors~! 