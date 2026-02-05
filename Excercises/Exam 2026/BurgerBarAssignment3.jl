# Question 9 - Assignment 3
using HiGHS, JuMP

# PARAMETERS
include("BurgerBarData.jl")




# MODEL
BB = Model(HiGHS.Optimizer)

# Decision Variables

@variable(BB, x[1:E,1:D,1:H], Bin)
@variable(BB, f[1:E,1:D], Bin)
@variable(BB, dev[1:E] >= 0)

# Objective
@objective(BB, Min, sum(dev[e] for e=1:E))


# Constraints
@constraint(BB, [d=1:D,h=1:H], sum(x[e,d,h] for e=1:E) == WorkerDemand[d,h])

@constraint(BB, [e=1:E], sum(x[e,d,h] for d=1:D,h=1:H) >= Target[e] - 2)
@constraint(BB, [e=1:E], sum(x[e,d,h] for d=1:D,h=1:H) <= Target[e] + 2)

@constraint(BB, [e=1:E,d=1:D,h=1:H], f[e,d] >= x[e,d,h])

@constraint(BB, [e=1:E,d=1:D], sum(x[e,d,h] for h=1:H) >= 2 * f[e,d])

@constraint(BB, [e=1:E,d=1:D,h=1:H], x[e,d,h] <= (h>1 ? x[e,d,h-1] : 0) + f[e,d])

@constraint(BB, [e=1:E], f[e,6] + f[e,7] <= 1)


@constraint(BB, [e=1:E], sum(x[e,d,h] for d=1:D,h=1:H) - Target[e] <= dev[e])
@constraint(BB, [e=1:E], Target[e] - sum(x[e,d,h] for d=1:D,h=1:H) <= dev[e])


# SOLVE
optimize!(BB)
if termination_status(BB) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(BB))")
else
    println("No optimal solution available")
end

z1 = objective_value(BB)

@constraint(BB, sum(dev[e] for e=1:E) <= z1)


@objective(BB, Min, sum(f[e,d] for e=1:E,d=1:D))


optimize!(BB)
if termination_status(BB) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(BB))")
else
    println("No optimal solution available")
end

