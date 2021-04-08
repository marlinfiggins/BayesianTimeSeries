struct LinearTrend{T} <: TimeSeriesNode where {T <: Int}
    N_change::T
end

function LinearTrend(N_change::T) where {T<: Int}
    return LinearTrend{T}(N_change)
end

params(TS::LinearTrend) = (TS.N_change)
params_shape(TS::LinearTrend) = (Int(TS.N_change + 1))
get_components(TS::LinearTrend) = TS
get_priors(TS::LinearTrend) = vcat(fill(Distributions.Normal(0.0, 5.0), params_shape(TS) - 1)..., Distributions.Normal(0.0, 20.0))

# Really Want Random Walk Prior

function (TS::LinearTrend{T})(δ, m, t)  where {T <: Int}
    #s = LinRange(0, maximum(t), TS.N_change)[2:end]
    #return make_trend(δ, s, m, t)
    return make_trend(δ, LinRange(0, maximum(t), TS.N_change)[2:end], m, t)
end

function (TS::LinearTrend{T})(θ, t)  where {T <: Int}
    #δ = [θ[i] for i in 1:TS.N_change ]
    #m = θ[end]
    #s = LinRange(0, maximum(t), TS.N_change)[2:end]

    #return make_trend(δ, s, m, t)
    return make_trend([θ[i] for i in 1:TS.N_change ], 
           LinRange(0, maximum(t), TS.N_change)[2:end],
           θ[end],
           t)
end

# Better way of doing this is to save index. Because each t is in exactly one interval.

"""
This function creates the vector for indexing trend values.
"""
function make_A(t, s)
    T, S = length(t), length(s)
    A = ones(Int64, T)
        for i in 1:T
            for j in 1:(S - 1)
                if (s[j+1] >= t[i] > s[j])
                    #A[i] = (j + 1)
                    A[i] += j
                end
            end
            if t[i] > s[end]
                #A[i] = (S  + 1)
                A[i] += S
            end
        end
    return A
end

## In Prophet, linear trend is given by
## (k + Aδ)t + (m + A(-sδ)),
## Where k is initial growth and (m + A(-s δ)) is the offset
## Here, we use δ as the intitial growth and the other delta represent the piecewise growth rate
function make_growth(δ, s, A)
    @assert (length(δ) - length(s)) == 1
    #A = make_A(t, s)
    #trend =  [ δ[i] for i in A]
    return [δ[i] for i in A]
end

function make_offset(δ, s, m, A)
    @assert (length(δ) - length(s)) == 1
    
    # Shift the piecewise linear fit
    #acc_thus = [ (i>1) ? sum(δ[1:(i-1)] .* ([s[1]; diff(s[1:(i-1)])])) : 0 for i in A]
    #time_change = [ (i>1) ? -δ[i] .* s[i-1] : 0 for i in A]
    #return m .+ acc_thus + time_change
    return m .+ [ (i>1) ? sum(δ[1:(i-1)] .* ([s[1]; diff(s[1:(i-1)])])) - (δ[i] .* s[i-1]) : 0 for i in A]
end

function make_trend(δ, s, m, t)
    # Add functionality to compute A once and a m
    A = make_A(t, s)
    #growth = make_growth(δ, s, A)
    #offset = make_offset(δ,s, m, A) 

    #return growth .* t + offset

    return make_growth(δ, s, A) .* t + make_offset(δ,s, m, A)  
end
