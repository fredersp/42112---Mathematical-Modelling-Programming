#************************************************************************
# Aircraft Landing 2, "Mathematical Programming Modelling" (42112)
# Intro definitions
#************************************************************************
using JuMP
using Gurobi
Early = [125 187 94 99 111 123 129 131 142 155]
Target = [155 212 134 127 123 138 145 157 162 179]
Late = [473 612 508 421 511 515 525 407 500 612]
delta = [10 20 35 25 35 30 30 50 30 35] #earliness penalty

rho = [10 20 35 25 35 30 30 50 30 35] #lateness penalty
Sep = [0 5 15 15 15 15 15 10 15 5;
    5 0 15 15 10 15 10 15 15 15;
    15 15 0 10 15 10 15 10 15 10;
    15 15 10 0 10 10 10 15 15 15;
    15 10 15 10 0 10 5 10 15 5;
    15 15 10 10 10 0 15 15 15 15;
    15 10 15 10 5 15 0 10 5 10;
    10 15 10 15 10 15 10 0 10 15;
    15 15 15 15 15 15 5 10 0 10;
    5 15 10 15 5 15 10 15 10 0];
n = 10
M = maximum(Late) - minimum(Early)
#************************************************************************
# MODEL
AL = Model(Gurobi.Optimizer)
#arrival time variables
@variable(AL, t[i=1:n] >= 0, Int)
#the number of minutes plane i arrives early
@variable(AL, e[i=1:n] >= 0, Int)
#the number of minutes plane i arrives late
@variable(AL, l[i=1:n] >= 0, Int)
#binary sequence variables
@variable(AL, x[i=1:n, j=1:n], Bin)
#the position of aircraft i in the landing sequence
@variable(AL, p[i=1:n] >= 0)
#objective - minimize total penalty
@objective(AL, Min, sum(delta[i]*e[i] + rho[i]*l[i] for i=1:n))
#onnection between target time, mins late, mins early, and arrival time
@constraint(AL, [i=1:n], t[i] == Target[i] - e[i] + l[i])
#bounding the mins late and mins early
@constraint(AL, [i=1:n], l[i] <= Late[i] - Target[i])
@constraint(AL, [i=1:n], e[i] <= Target[i] - Early[i])
#enforcing minimum separation time between pairs of aircraft
@constraint(AL, [i=1:n, j=1:n; i!=j], t[i] + Sep[i,j] <= t[j] + (Sep[i,j] + M)*(1-x[i,j]))
# either i before j, or j before i:
@constraint(AL, [i=1:n, j=1:n; i!=j], x[i,j] + x[j,i] == 1)
#set position variables based on relation variables:
@constraint(AL, [i=1:10], p[i] == sum(x[j,i] for j=1:n if i!=j) + 1)
#5/6 not consecutive:
@constraint(AL, p[6] >= p[5] + 2 - (n+1)*(1-x[5,6]))
@constraint(AL, p[5] >= p[6] + 2 - (n+1)*(1-x[6,5]))

optimize!(AL)
if termination_status(AL) == MOI.OPTIMAL
    println("\nOptimal Objective Value: $(objective_value(AL))")
    println("\nAircraft Landing times and position\n")
    for i=1:n
     println("Aircraft $i: time = $(round(value(t[i]), digits=2)), position = $(round(Int, value(p[i])))")
    end
else
    println("No Solution:")
end
