using JuMP, Gurobi

############################################
# PARAMETERS

include("FoodFestival_data.jl")

W = 25


################################################
# MODEL
FF = Model(Gurobi.Optimizer)

# Decision variables

# If worker w is hired
@variable(FF, x[1:W], Bin)

# Which worker w take shift s
@variable(FF, y[1:W,1:S], Bin)

# Objective
# Minimize the number of hired workers
@objective(FF, Min, sum(x[w] for w=1:W))

# Constraints
# We can only assign a hired worker to a shift
@constraint(FF, [w=1:W,s=1:S], x[w] >= y[w,s])

# We only look at the shifts with conflicts
@constraint(FF, [s1=1:S,s2=1:S,w=1:W; Conflict[s1,s2] == 1], y[w,s1] + y[w,s2] <= 1)

# All shifts must be covered
@constraint(FF, [s=1:S], sum(y[w,s] for w=1:W) >= 1)

##################################################

# SOLVE
optimize!(FF)

if termination_status(FF) == MOI.OPTIMAL
        println("Optimal objective value: $(objective_value(FF))")
    else
        println("No optimal solution available")
end    




