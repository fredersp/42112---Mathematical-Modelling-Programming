using JuMP, Gurobi

#####################################################################
# PARAMETERS
include("wind_farm_data.jl")

# Scenario 1 
cost_scenario_1 = [135, 250, 480]
max_capacity_scenario_1 = [2, 6, 9]

# Scenario 2
cost_scenario_2 = [170, 290, 610]
max_capacity_scenario_2 = [3, 7, 13]

T = length(cost_scenario_1)
W = size(Distance, 1)

#####################################################################

#####################################################################
# MODEL
WF = Model(Gurobi.Optimizer)

# DECISION VARIABLES
# If a cable is routed between w1 and w2
@variable(WF, x[1:T,1:W,1:W], Bin)

# OBJECTIVE FUNCTION
@objective(WF, Min, sum(x[t,w1,w2] * Distance[w1,w2] * cost_scenario_1[t] for t=1:T,w1=1:W,w2=1:W))

# CONSTRAINTS
@constraint(WF, sum(x[t,w1,35] for t=1:T,w1=1:W) <= 4)

@constraint(WF, [w1=1:W], sum(x[t,w1,w2] for t=1:T,w2=1:W) == 1)

@constraint(WF, [t=1:T,w2=1:W], sum(x[t,w1,w2] for w1=1:W) <= max_capacity_scenario_1[t])
@constraint(WF, [t=1:T, w1=1:W], x[t,w1,w1] == 0)

#####################################################################

# SOLVE
optimize!(WF)

if termination_status(WF) == MOI.OPTIMAL
        println("Optimal objective value: $(objective_value(WF))")
    else
        println("No optimal solution available")
end    



#####################################################################

