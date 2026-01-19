#Stamp bid

using JuMP, HiGHS

include("stamp_bid_data.jl")

#Parameters
B = length(BidPrice)

S = size(BidSets, 2)

#Model

SB = Model(HiGHS.Optimizer)

@variable(SB, x[1:B], Bin)

@objective(SB, Max, sum(x[b]*BidPrice[b] for b in 1:B))

@constraint(SB, [s=1:S], sum(BidSets[b,s] *x[b] for b=1:B)<=1)

optimize!(SB)
println("Objective value: $(objective_value(SB))")


