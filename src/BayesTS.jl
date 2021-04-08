module BayesTS

#import Base: size, length, rand
#import Base: sum, maximum, minimum, +, -. ==

export 
    # Types
    TimeSeriesNode,
    SumTSNodes,
    ProdTSNodes,
    ## Individual Components
    FourierSeasonality,
    LinearTrend,
    params, # Methods
    params_shape,
    get_components,
    get_priors, # Inference
    unpack_parms,
    sample_turing,
    sample_chain,
    sample_predictive,
    sample_time_series, # Testing
    fourier_sum

# Include Files
include("TimeSeriesNodes.jl")
include("FourierSeasonality.jl")
include("LinearTrend.jl")
include("TuringInference.jl")
include("InferenceHelpers.jl")
end