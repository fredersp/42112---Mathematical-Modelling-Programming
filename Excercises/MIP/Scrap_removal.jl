#Scrap removal
using JuMP, HiGHS

#Parameters
w = [35 10 45 53 37 22 26 38 63 17 44 54 62 42 39 51 24 52 46 29]

cost = 50
Limit = 100
B = 10
I = length(w)

#Model

SR = Model(HiGHS.Optimizer)

@variable(SR, x[1:I, 1:B], Bin)
@variable(SR, y[1:B], Bin)

@objective(SR, Min, sum(y[b]*cost for b=1:B))

#Weight constraint pr bag
@constraint(SR, [b=1:B], sum(w[i]*x[i,b] for i=1:I)<=Limit*y[b])


#Every item has to be in exactly 1 bag
@constraint(SR, [i=1:I], sum(x[i,b] for b=1:B)==1)

optimize!(SR)
println("Objective", objective_value(SR))