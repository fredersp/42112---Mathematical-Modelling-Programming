# Question 9 - Assignment 1
using HiGHS, JuMP

# PARAMETERS
include("BurgerBarData.jl")




# MODEL
BB = Model(HiGHS.Optimizer)

# Decision Variables

@variable(BB, x[1:E,1:D,1:H], Bin)
@variable(BB, f[1:E,1:D], Bin)

# Objective
@objective(BB, Min, sum(f[e,d] for e=1:E,d=1:D))

# Constraints
@constraint(BB, [d=1:D,h=1:H], sum(x[e,d,h] for e=1:E) == WorkerDemand[d,h])

@constraint(BB, [e=1:E], sum(x[e,d,h] for d=1:D,h=1:H) >= Target[e] - 2)
@constraint(BB, [e=1:E], sum(x[e,d,h] for d=1:D,h=1:H) <= Target[e] + 2)

@constraint(BB, [e=1:E,d=1:D,h=1:H], f[e,d] >= x[e,d,h])

@constraint(BB, [e=1:E,d=1:D], sum(x[e,d,h] for h=1:H) >= 2 * f[e,d])

@constraint(BB, [e=1:E,d=1:D,h=1:H], x[e,d,h] <= (h>1 ? x[e,d,h-1] : 0) + f[e,d])


# SOLVE
optimize!(BB)
if termination_status(BB) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(BB))")
else
    println("No optimal solution available")
end
