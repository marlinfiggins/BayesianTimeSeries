
abstract type TimeSeriesNode end

n_components(TS::TimeSeriesNode) = 1
get_components(TS::TimeSeriesNode) = TS

function get_components(NodeL::TimeSeriesNode, NodeR::TimeSeriesNode)
    component_list = []

    comp_left = NodeL
    comp_right = NodeR

    if (typeof(comp_left) <: SumTSNodes || typeof(comp_left) <: ProdTSNodes )
        push!(component_list, get_components(comp_left)...)
    else 
        push!(component_list, comp_left)
    end
    
    if (typeof(comp_right) <: SumTSNodes || typeof(comp_right) <: ProdTSNodes )
        push!(component_list, get_components(comp_right)...)
    else
        push!(component_list, comp_right)
    end
    return component_list
end

## Need to define structures and methods on these structures.
## Struct SumOfNodes ProdOfNodes

struct SumTSNodes <: TimeSeriesNode
    NodeL::TimeSeriesNode
    NodeR::TimeSeriesNode
    Components::Array{TimeSeriesNode, 1}

    SumTSNodes(L, R) = new(L, R, get_components(L, R)) 
end

Base.:+(NodeL::TimeSeriesNode, NodeR::TimeSeriesNode) = SumTSNodes(NodeL, NodeR)

params_shape(TS::SumTSNodes) = params_shape.(TS.Components)
n_components(TS::SumTSNodes) = length(TS.Components)
get_components(TS::SumTSNodes) = TS.Components

function (TS::SumTSNodes)(θ, t)
    # Need to Mark Sure θ is a vector of arrays with the right size for each comp
    # Get Params of Right Size for Each Component
   return sum(TS.Components[c](θ[c], t) for c in 1:n_components(TS))
end

struct ProdTSNodes <: TimeSeriesNode
    NodeL::TimeSeriesNode
    NodeR::TimeSeriesNode
    Components::Array{TimeSeriesNode, 1}

    ProdTSNodes(L, R) = new(L, R, get_components(L, R)) 
end

Base.:*(NodeL::TimeSeriesNode, NodeR::TimeSeriesNode) = ProdTSNodes(NodeL, NodeR)

params_shape(TS::ProdTSNodes) = params_shape.(TS.Components)
n_components(TS::ProdTSNodes) = length(TS.Components)
get_components(TS::ProdTSNodes) = TS.Components

## Need Add Mult, Fit 

## Example Code

## week_season = FourierSeasonality(3, 7.0)
## year_season = FourierSeasonality(10, 365.0)
## total_trend = LinearTrend(20.0)

## TimeSeriesModel = total_trend + year_season + week_season

## fit(TimeSeriesModel, t, data)

## This object needs to be able to save a chain, so it can be sampled from easily.
## Want two or three methods: post sample, prior sample, post-pred.


## When I call Structure with an Abstract Vector I want to evalute

## What option to make estiamte Hierarchical for various groups.
## Focus on a single time series first nerd


## Need method to return number of parameters


## Make Method for Shape and Size of params i.e. each Seasonality gets a β_? of size (F_nodes, 2)