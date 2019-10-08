"""

    u,v,η,sst = RunJuls()

runs Juls with default parameters as defined in src/DefaultParameters.jl

# Examples
```jldoc
julia> u,v,η,sst = RunJuls(Float64,nx=200,output=true)
```
"""
function RunJuls(::Type{T}=Float32;     # number format
    kwargs...                           # all additional parameters
    ) where {T<:AbstractFloat}

    P = Parameter(T=T;kwargs...)
    return RunJuls(T,P)
end

function RunJuls(;P::Parameter)
    @unpack T = P
    return RunJuls(T,P)
end

function RunJuls(::Type{T},P::Parameter) where {T<:AbstractFloat}

    G = Grid{T}(P)
    C = Constants{T}(P,G)
    Prog = initial_conditions(T,P,G)
    Diag = preallocate(T,G)
    #TimeIntegration!(P,G,C,Prog,Diag)
    return Diag
end