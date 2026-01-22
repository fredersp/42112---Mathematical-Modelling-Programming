using HiGHS, JuMP

#########################################
# PARAMETERS
items = [35 10 45 53 37 22 26 38 63 17 44 54 62 42 39 51 24 52 46 29]

I = length(items)
B = 10
cost = 50

#########################################
# MODEL
SR = Model(HiGHS.Optimizer)

# DECISION VARIABLES
@variable(SR, y[1:I,1:B], Bin)
@variable(SR, x[1:B], Bin)

# OBJECTIVE
@objective(SR, Min, sum(x[b] * cost for b=1:B))


# CONSTRAINTS
@constraint(SR, [b=1:B], sum(y[i,b] * items[i] for i=1:I) <= 100)

@constraint(SR, [i=1:I], sum(y[i,b] for b=1:B) == 1)

@constraint(SR, [i=1:I,b=1:B], x[b] >= y[i,b])

optimize!(SR)
println("Objective: ", objective_value(SR))



