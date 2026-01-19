using JuMP, Gurobi

#############################################################
# PARAMETERS
include("WeddingData20.jl")

#############################################################

#############################################################
# MODEL 
WP = Model(Gurobi.Optimizer)

# Decision variables

# Binary variable that assigns each guest g to table t
@variable(WP, x[1:G,1:T], Bin)
@variable(WP, y[1:G,1:G,1:T], Bin) # If two guests are seated together
@variable(WP, z[1:T]) # Help variable for gender amount difference
@variable(WP, w[1:G] >= 0)
@variable(WP, q[1:G,1:G,1:T], Bin) # 


# Objective
# @objective(WP, Min, T) # No objective, just feasibility
# @objective(WP, Max, sum(y[g1,g2,t] * SharedInterests[g1,g2] for g1=1:G,g2=1:G,t=1:T))
# @objective(WP, Min, sum(z[t] for t=1:T)) # Minimize the gender gap
# @objective(WP, Min, sum(w[g] for g=1:G))

@objective(WP, Min, -sum(y[g1,g2,t] * SharedInterests[g1,g2] for g1=1:G,g2=1:G,t=1:T) +
  sum(z[t] for t=1:T) + sum(w[g] for g=1:G))


# Constraints
@constraint(WP, [g=1:G], sum(x[g,t] for t=1:T) == 1)

@constraint(WP, [t=1:T], sum(x[g,t] for g=1:G) <= TableCap)

# We only look at the shifts with conflicts
@constraint(WP, [g1=1:G,g2=1:G,t=1:T; Couple[g1,g2] == 1], x[g1,t] - x[g2,t] <= 0)

# See Logic 6.3, make sures that we count the correct guest pairs
@constraint(WP, [g1=1:G,g2=1:G,t=1:T], y[g1,g2,t] >= (g1 < g2 ? x[g1,t] + x[g2,t] - 1 : 0))
@constraint(WP, [g1=1:G,g2=1:G,t=1:T], y[g1,g2,t] <= (g1 < g2 ? x[g1,t] : 0))
@constraint(WP, [g1=1:G,g2=1:G,t=1:T], y[g1,g2,t] <= (g1 < g2 ? x[g2,t] : 0))

# Female and male constraints, make sure z becomes the positive difference of male and female
@constraint(WP, [t=1:T], z[t] >= sum(Male[g] * x[g,t] for g=1:G) - sum(Female[g] * x[g,t] for g=1:G))
@constraint(WP, [t=1:T], z[t] >= sum(Female[g] * x[g,t] for g=1:G) - sum(Male[g] * x[g,t] for g=1:G))
@constraint(WP, [t=1:T], z[t] >= 0)
@constraint(WP, [t=1:T], z[t] <= 2)

# COnstraints for minimizing the penalty
@constraint(WP, [t=1:T,g1=1:G], w[g1] >= 3 - sum(q[g1,g2,t] * Know[g1,g2] for g2=1:G))


##################################################

# SOLVE
optimize!(WP)

if termination_status(WP) == MOI.OPTIMAL
        println("Optimal objective value: $(objective_value(WP))")
    else
        println("No optimal solution available")
end    



# Print x[g,t]
for g in 1:G
    for t in 1:T
        if value(x[g,t]) > 0.5
            println("Guest $g is assigned to table $t")
        end
    end
end

