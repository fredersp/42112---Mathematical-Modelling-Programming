using JuMP, Gurobi

include("WorkPlanData.jl")

#############################################
# PARAMETERS
# D: Days
# P: Periods
# Demand: TA demand for each period each day
# TA's: List of TA's name

# Total Working hours pr. TA
TotalWork = 52

#############################################

#############################################
# MODEL
WP = Model(Gurobi.Optimizer)

# Decision Variables
# Binary variable for each TA, if they work the specific timeslot
@variable(WP, x[1:TA,1:P,1:D], Bin)

# Binary variable if TA works on a day
@variable(WP, y[1:TA,1:P,1:D], Bin)

# Objective function
# Minimize the number of inconvenient hours for TA's
@objective(WP, Min, sum(x[ta,p,d]*Inconvenience[ta,p,d] for ta=1:TA, p=1:P, d=1:D))

# Constraints
# For each period each demand must be met
@constraint(WP, [p=1:P,d=1:D], sum(x[ta,p,d] for ta=1:TA) == Demand[p,d])

# Each TA must work 52 hours
@constraint(WP, [ta=1:TA], sum(x[ta,p,d] for p=1:P,d=1:D) == TotalWork)



@constraint(WP, [ta=1:TA,d=1:D], sum( y[ta,p,d] for p=1:P) <= 1 )
# require connected work plans
@constraint(WP, [ta=1:TA,d=1:D,p=1:P], x[ta,p,d] <= (p>1 ? x[ta,p-1,d] : 0) + y[ta,p,d])

# at least 2 hours of work pr. day if working that day
@constraint(WP, [ta=1:TA,d=1:D], sum( x[ta,p,d] for p=1:P) >= 2*sum( y[ta,p,d] for p=1:P) )

########################################
# SOLVE
optimize!(WP)
if termination_status(WP) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(WP))")
else
    println("No optimal solution available")
end


