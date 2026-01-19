#*******************************************
# Jewellery Problem, LP, Day 1
using JuMP, Gurobi
#*******************************************

#*******************************************
# PARAMETERS
Demand = [15, 30, 25, 55, 75, 115, 190, 210, 105, 65, 20, 20]

Cost = 1 

Time = ["1","2","3","4","5", "6", "7", "8", "9", "10", "11", "12"]
T = length(Time)


#***********************************************

#***********************************************
# Model
BW = Model(Gurobi.Optimizer)

# Production
@variable(BW, 0 <= p[1:T] <= 120)

# Storage
@variable(BW, 0 <= s[1:T] <= 200)

@objective(BW, Min, sum(Cost*s[t] for t = 1:T))

@constraint(BW, [t=1:T], p[t] + (t>1 ? s[t-1] : 0) >= Demand[t])

@constraint(BW, [t=1:T], p[t] + (t>1 ? s[t-1] : 0) - Demand[t] == s[t])

@constraint(BW, p[1] >= Demand[1])

#************************************************


#*************************************************
# Solve
optimize!(BW)
println("Termination status: $(termination_status(BW))")
#**************************************************

#*************************************************
# Solution 
if termination_status(BW) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(BW))")
    for t = 1:T
        println("Production: ", value(p[t]))
        println("Storage: ", value(s[t]))
    end
else
    println("No optimal solution available")
end

