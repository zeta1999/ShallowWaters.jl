struct Constants{T<:AbstractFloat,Tprog<:AbstractFloat}

    # RUNGE-KUTTA COEFFICIENTS 3rd/4th order including timestep Δt
    RKaΔt::Array{Tprog,1}
    RKbΔt::Array{Tprog,1}

    # BOUNDARY CONDITIONS
    one_minus_α::Tprog      # tangential boundary condition for the ghost-point copy

    # PHYSICAL CONSTANTS
    g::T                    # gravity
    cD::T                   # quadratic bottom friction - incl grid spacing
    rD::T                   # linear bottom friction - incl grid spacing
    γ::T                    # frequency of interface relaxation
    cSmag::T                # Smagorinsky constant
    νB::T                   # biharmonic diffusion coefficient
    rSST::T                 # tracer restoring timescale
    jSST::T                 # tracer consumption timescale
    SSTmin::T               # tracer minimum
    ωyr::Float64            # frequency [1/s] of Kelvin pumping (including 2π)
end

"""Generator function for the mutable struct Constants."""
function Constants{T,Tprog}(P::Parameter,G::Grid) where {T<:AbstractFloat,Tprog<:AbstractFloat}

    # Runge-Kutta 3rd/4th order coefficients including time step Δt
    # (which includes the grid spacing Δ too)
    if P.RKo == 3     # version 2
        RKaΔt = Tprog.([1/4,0.,3/4]*G.dtint/G.Δ)
        RKbΔt = Tprog.([1/3,2/3]*G.dtint/G.Δ)
    elseif P.RKo == 4
        RKaΔt = Tprog.([1/6,1/3,1/3,1/6]*G.dtint/G.Δ)
        RKbΔt = Tprog.([.5,.5,1.]*G.dtint/G.Δ)
    end

    one_minus_α = Tprog(1-P.α)    # for the ghost point copy/tangential boundary conditions
    g = T(P.g)                # gravity - for Bernoulli potential

    # BOTTOM FRICTION COEFFICENTS
    # incl grid spacing Δ for non-dimensional gradients
    cD = T(-G.Δ*P.cD)             # quadratic drag [m]
    rD = T(-G.Δ/(P.τD*24*3600))   # linear drag [m/s]

    # INTERFACE RELAXATION FREQUENCY
    # incl grid spacing Δ for non-dimensional gradients
    γ = T(G.Δ/(P.t_relax*3600*24))    # [m/s]

    # BIHARMONIC DIFFUSION
    cSmag = T(-P.cSmag)   # Smagorinsky coefficient
    νB = T(-P.νB/30000)   # linear scaling based on 540m^s/s at Δ=30km

    # TRACER ADVECTION
    rSST = T(G.dtadvint/(P.τSST*3600*24))    # tracer restoring [1]
    jSST = T(G.dtadvint/(P.jSST*3600*24))    # tracer consumption [1]
    SSTmin = T(P.SSTmin)

    # SURFACE FORCING
    ωyr = -2π*P.ωyr/24/365.25/3600

    return Constants{T,Tprog}(RKaΔt,RKbΔt,one_minus_α,g,cD,rD,γ,cSmag,νB,rSST,jSST,SSTmin,ωyr)
end
