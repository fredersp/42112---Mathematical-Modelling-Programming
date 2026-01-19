using JuMP, Gurobi

##################################################
# PARAMETERS
demand = [15000 30000 25000 40000 27000] # for each timeslot in MW

# Minimum levels for each type
min_level = [850 1250 1500]

# Maximum level for each type
max_level = [2000 1750 4000]

# minumum cost per hour for each generator type
min_cost = [1000 2600 3000]

# hourly cost per MW for each generator type
hour_cost = [2 1.3 3]

# start up cost for each generator type
start_cost = [2000 1000 500]

T = length(start_cost)
H = 24

max_type = [12 10 5]

##################################################
# MODEL
TR = Model(Gurobi.Optimizer)

# DECISION VARIABLES
@variable(TR, g[1:T,1:H] >= 0, Int)
@variable(TR, s[1:T,1:H] >= 0, Int)
@variable(TR, p[1:T,1:H] >= 0)

# OBEJCTIVE FUNCTION
@objective(TR, Min, sum(g[t,h] * min_cost[t] for t=1:T, h=1:H) 
            + sum(s[t,h] * start_cost[t] for t=1:T,h=1:H) 
            + sum((p[t,h] - min_level[t] * g[t,h]) * hour_cost[t] for t=1:T, h=1:H)
)


# CONSTRAINTS
@constraint(TR, [t=1:T,h=1:H], p[t,h] >= g[t,h] * min_level[t])
@constraint(TR, [t=1:T,h=1:H], p[t,h] <= g[t,h] * max_level[t])

@constraint(TR, [t=1:T,h=1:H], g[t,h] <= max_type[t])
@constraint(TR, [t=1:T,h=1:H], s[t,h] <= max_type[t])

@constraint(TR, [t=1:T,h=2:H], g[t,h] - g[t,h-1] <= s[t,h])
@constraint(TR, [t=1:T], g[t,1] - g[t,24] <= s[t,1])

@constraint(TR, sum(p[t,h] for t=1:T,h=1:6) >= demand[1])
@constraint(TR, sum(p[t,h] for t=1:T,h=7:9) >= demand[2])
@constraint(TR, sum(p[t,h] for t=1:T,h=10:15) >= demand[3])
@constraint(TR, sum(p[t,h] for t=1:T,h=16:18) >= demand[4])
@constraint(TR, sum(p[t,h] for t=1:T,h=19:24) >= demand[5])


@constraint(TR, sum(g[t,h] * max_level[t] for t=1:T,h=1:6) >= demand[1] * 1.15)
@constraint(TR, sum(g[t,h] * max_level[t] for t=1:T,h=7:9) >= demand[2] * 1.15)
@constraint(TR, sum(g[t,h] * max_level[t] for t=1:T,h=10:15) >= demand[3] * 1.15)
@constraint(TR, sum(g[t,h] * max_level[t] for t=1:T,h=16:18) >= demand[4] * 1.15)
@constraint(TR, sum(g[t,h] * max_level[t] for t=1:T,h=19:24) >= demand[5] * 1.15)

##################################################

# SOLVE
optimize!(TR)

if termination_status(TR) == MOI.OPTIMAL
        println("Optimal objective value: $(objective_value(TR))")
    else
        println("No optimal solution available")
end    













