using JuMP, Gurobi


###########################################
# PARAMETERS

include("unit_arrival_departure_info.jl")


U = length(arrival)
tracklength = [500 800 700 400 650 650 750 500]
T = length(tracklength)

conflict = zeros(Int64,U,U)

# Chech if there is a conflict, so if train i arrives before j and have to leave before j
for i=1:U
    for j=1:U
        if arrival[i] < arrival[j] && depart[i] < depart[j]
            conflict[i,j] = 1
        end
    end
end


# Check when i arrives if j is still in the depot or have left
local indepot = zeros(Int64,U,U)

for i=1:U
    for j=1:U
        if arrival[i] > arrival[j] && depart[j] > arrival[i]
            indepot[i,j] = 1
        end
    end
end


conflicttype = zeros(Int64,U,U)

for i=1:U
    for j=1:U
        if arrival[i] > arrival[j] && depart[j] > arrival[i] && type[i] != type[j]
            conflicttype[i,j] = 1
        end
    end
end





#############################################
# MODEL
RD = Model(Gurobi.Optimizer)

# DECISION VARIABLES
# Binary variable that checks if unit i is parked on track t
@variable(RD, x[1:U,1:T], Bin)

# OBJECTIVE
@objective(RD, Max, sum(x[i,t] for i=1:U,t=1:T))


# CONSTRAINTS 
# Make sure that a unit is only parked at one tract at max
@constraint(RD, [i=1:U], sum(x[i,t] for t=1:T) <= 1)

# If there is a time conflict i and j cannot park at the same track
@constraint(RD, [i=1:U-1,j=2:U,t=1:T;conflict[i,j] == 1], x[i,t] + x[j,t] <= 1)

# Make sure the length of the tracks are not exceeded
@constraint(RD, [t=1:T, j=1:U], sum(indepot[i,j] * x[i,t] * 42 * type[i] for i=1:U) <= tracklength[t])

# If there is a type conflict i and j cannot park at the same track
@constraint(RD, [i=1:U-1,j=2:U,t=1:T;conflicttype[i,j] == 1], x[i,t] + x[j,t] <= 1)



################################################
# SOLVE

optimize!(RD)
println("Optimal objective value: $(objective_value(RD))")





