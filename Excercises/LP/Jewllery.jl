#*******************************************
# Jewellery Problem, LP, Day 1
using JuMP, Gurobi
#*******************************************

#*******************************************
# PARAMETERS
Necklaces = ["1","2","3","4","5"]
N = length(Necklaces)
Machines = ["1", "2", "3"]
M = length(Machines)

Profit = [50, 45, 85, 60, 55]

Time = 450


# Production time usage for each necklace to one matrix
TimeUsageMachine = [
    7 0 0 9 0;
    5 7 11 0 5;
    0 3 8 15 3;
]

workers = 3

# Time for assembly for two workers
TimeUsageAssembly = [
    12/workers 3/workers 11/workers 9/workers 6/workers
]

AverageDemand = [
    25 10 12 15 60
]

#***********************************************

#***********************************************
# Model
JW = Model(Gurobi.Optimizer)

@variable(JW, x[1:N] >= 0)

@objective(JW, Max, sum(Profit[n]*x[n] for n = 1:N))

@constraint(JW, [m=1:M], sum(TimeUsageMachine[m,n]*x[n] for n = 1:N) <= Time)

@constraint(JW, sum(TimeUsageAssembly[n]*x[n] for n =1:N) <= Time)

# Constraint for 1.2
@constraint(JW, [n=1:N], x[n] <= AverageDemand[n])

#************************************************


#*************************************************
# Solve
optimize!(JW)
println("Termination status: $(termination_status(JW))")
#**************************************************

#*************************************************
# Solution 
if termination_status(JW) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(JW))")
    for n = 1:N
        println("x[", Necklaces[n], "] : ", value(x[n]))
    end
else
    println("No optimal solution available")
end

