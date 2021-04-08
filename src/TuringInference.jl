using Turing

# Set Default Priors for Various Components

function sample_turing(
    TS::TimeSeriesNode,
    t,
    data;
    num_samples = 500,
    sampler = Turing.NUTS(0.65),
    priors = get_priors.(TS.Components),
    likeihood = (μ, σ) -> Normal(μ, σ)
)

    ## Get List of Cof Components
    comps = TS.Components

    # Get List of Priors Based on TypeOfComponent 
    num_comp = n_components(TS)

    # Get parameter shapes for each component
    p_shapes = params_shape(TS)

    # VECTOR OF PRIORS
    #priors = get_priors.(comps)

    # Number
    ## Name Variable Names
    syms = [Turing.@varname(theta[i]) for i in 1:length(priors)]  

    ## For Seasonality Components
    Turing.@model function ts_mf(data, t) where {T <: Real}
        
        #  VECTOR OF PARMS
        theta = Vector{Any}(undef, num_comp)        

        # Fill Out Priors
        for c in 1:num_comp
            #println("Starting $(comps[c])")
            theta[c] = Array{Any}(undef, p_shapes[c]...)

            for i in eachindex(theta[c])
                #theta[c][i] ~  NamedDist(priors[c], syms[c])
                theta[c][i] ~ priors[c][i]
            end

            #println("Ending $(comps[c])")
        end

        # Evaluate Model Using Parameters for All Compnents

        pred_mean = TS(theta, t)
        σ ~ InverseGamma(2, 3)      
        
        #pred_mean = comps[1](theta[1], t)

        #for c in 2:num_comp
        #    pred_mean += comps[c](theta[c], t)
        #end

        for i in 1:length(data)
            data[i] ~ likeihood(pred_mean[i], σ)
        end
    end

    model = ts_mf(data, t)
    chain = sample(model, sampler, num_samples)
    return chain
end
