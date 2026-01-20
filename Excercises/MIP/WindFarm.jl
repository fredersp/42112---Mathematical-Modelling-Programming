using JuMP, Gurobi, Plots

#####################################################################
# PARAMETERS
include("wind_farm_data.jl")

# Scenario 1 
cost_scenario_1 = [135, 250, 480]
max_capacity_scenario_1 = [2, 6, 9]

# Scenario 2
cost_scenario_2 = [170, 290, 610]
max_capacity_scenario_2 = [3, 7, 13]

# Scenario  3
cost_scenario_3 = [135, 290, 610]
max_capacity_scenario_3 = [4, 6, 12]

C = length(cost_scenario_1)
N = size(Distance, 1)
M = 20

#####################################################################

#####################################################################
# MODEL
WF = Model(Gurobi.Optimizer)

# DECISION VARIABLES
# If a cable is routed between w1 and w2
@variable(WF, x[1:C,1:N,1:N], Bin)
# Helper variable to count the total outgoing cables from a wind turbine
@variable(WF, f[1:N,1:N] >= 0)

# OBJECTIVE FUNCTION
@objective(WF, Min, sum(x[c,w1,w2] * Distance[w1,w2] * cost_scenario_3[c] for c=1:C,w1=1:N,w2=1:N))

# CONSTRAINTS
# There must go one cable out from each wind turbine
@constraint(WF, [w1=1:N-1], sum(x[c,w1,w2] for c=1:C,w2=1:N) == 1)

# Counting variable, count how many windturbines (capacity) goes out of w1
@constraint(WF, [w1=1:N-1], sum(f[w2,w1] for w2=1:N-1) + 1 - sum(f[w1,w2] for w2=1:N) == 0)

# Make sure that the cable capacities are bounding the maximum capacities of the cables
@constraint(WF, [w1=1:N-1,w2=1:N], sum(max_capacity_scenario_3[c] * x[c,w1,w2] for c=1:C) >= f[w1,w2])

# Make sure that at most 4 connections goes into the substation
@constraint(WF, sum(x[c,w1,N] for c=1:C, w1=1:N-1) <= 3)

@constraint(WF, [c=1:C], x[c,21,13] == 0)  # No cable between substation and turbine 13
# Adding that the incoming to the substation must be balanced distributed
# @constraint(WF, [c=1:C,w1=1:N-1,w2=1:N-1], f[w1,N] - f[w2,N] <= 1 + M * (2 - x[c,w1,N] - x[c,w2,N]))

# @constraint(WF, [c=1:C,w1=1:N-1,w2=1:N-1], f[w1,N] - f[w2,N] >= -1 - M * (2 - x[c,w1,N] - x[c,w2,N]))

#####################################################################

# SOLVE
optimize!(WF)

if termination_status(WF) == MOI.OPTIMAL
        println("Optimal objective value: $(objective_value(WF))")
    else
        println("No optimal solution available")
end    

#####################################################################

dy = diff([extrema(yc)...])[1]/30  # adjust offset if needed
scatter(xc, yc, color=:black, xlabel="longitude", ylabel="latitude", legend=false)

for i=1:N
    annotate!(xc[i], yc[i]+dy, text(string(i),8))
end

for i=1:N
    for j=1:N
        for t=1:C
            if value(x[t,i,j]) > 1e-6
                if t==1
                    plot!([xc[i],xc[j]],[yc[i],yc[j]],legend=false, linecolor=:black)
                elseif t==2
                    plot!([xc[i],xc[j]],[yc[i],yc[j]],legend=false, linecolor=:blue)
                else     
                    plot!([xc[i],xc[j]],[yc[i],yc[j]],legend=false, linecolor=:green)
                end
            end
        end
    end
end

display(plot!())

