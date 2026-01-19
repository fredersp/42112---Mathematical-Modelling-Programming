# MOIP: Startup Fund Q1, Q2, Q3
using JuMP, Gurobi

############################################################
# PARAMETERS

EP = [29 35 24 52 53 41 43 68 28] # Expected profit

Cost = [17 25 19 25 28 23 29 31 18] # Cost

sdg = [8 6 8 3 4 5 3 2 7] # SDG score

J = length(EP)

#############################################################
# MODEL

SF = Model(Gurobi.Optimizer)

w = 1

@variable(SF, x[1:J], Bin)

@objective(SF, Max, sum(EP[j]*x[j] for j=1:J))

@constraint(SF, sum(x[j]*Cost[j] for j=1:J)<= 100)

##############################################################


# @constraint(SF, x[1] + x[5]<=1)

# @constraint(SF, x[2] + x[3] >= x[6])

# @constraint(SF, x[2] + x[3] >= x[9])




##############################################################

# Question 2
# optimize!(SF)
# println("SDG: $(objective_value(SF))")
# z1 = objective_value(SF)

# @objective(SF, Max, sum(EP[j] * x[j] for j=1:J))

# @constraint(SF, sum(x[j] * sdg[j] for j=1:J) >= z1)

# optimize!(SF)
# println("Profit: $(objective_value(SF))")

# Question 3
# optimize!(SF)
# println("Profit: $(objective_value(SF))")
# z1 = objective_value(SF)

# @objective(SF, Max, sum(x[j] * sdg[j] for j=1:J))

# @constraint(SF, sum(x[j] * EP[j] for j=1:J) >= z1)

# optimize!(SF)
# println("SDG: $(objective_value(SF))")
