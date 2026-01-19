#*******************************************
# Jewellery Problem, LP, Day 1
using JuMP, Gurobi
#*******************************************

#*******************************************
# PARAMETERS
Cost = [110 120 130 110 115]

Hardness = [8.8 6.1 2 4.2 5]

Price = 150 

Oil = ["VEG1","VEG2","OIL1","OIL2","OIL3"]
O = length(Oil)

#***********************************************

#***********************************************
# Model
BL = Model(Gurobi.Optimizer)

# Production
@variable(BL, x[1:O] >= 0)


@objective(BL, Max, sum(Price * x[o] - Cost[o] * x[o] for o = 1:O))
    
@constraint(BL, x[1] + x[2] <= 200)
@constraint(BL, x[3] + x[4] + x[5] <= 250)

@constraint(BL, sum(Hardness[o] * x[o] for o in 1:O) >= 3 * sum(x[o] for o in 1:O))
@constraint(BL, sum(Hardness[o] * x[o] for o in 1:O) <= 6 * sum(x[o] for o in 1:O))

#************************************************




#*************************************************
# Solve
optimize!(BL)
println("Termination status: $(termination_status(BL))")
#**************************************************

#*************************************************
# Solution 
if termination_status(BL) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(BL))")
    for o = 1:O
        println("Production: ", value(x[o]))
    end
else
    println("No optimal solution available")
end

