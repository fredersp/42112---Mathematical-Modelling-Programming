using JuMP, Gurobi

##########################################
# PARAMETERS

# Profit
profit = [10, 6, 8, 4, 11, 9, 3]

# Machine (rows), Product (columns)
process_time = [
    0.5 0.7 0 0 0.3 0.2 0.5;
    0.1 0.2 0 0.3 0 0.6 0;
    0.2 0 0.8 0 0 0 0.6;
    0.05 0.03 0 0.070 0.10 0 0.08;
    0 0 0.01 0 0.05 0 0.05;
]

monthly_hours = 16*24

instruments = ["Grinder", "Ver. Drill","Hor. Drill", "Borer", "Planer" ]

# Months (rows), Instruments (columns)
available_time = monthly_hours * [
    3 2 3 1 1;
    4 2 1 1 1;
    4 2 3 0 1;
    4 1 3 1 1;
    3 1 3 1 1;
    4 2 2 1 0;

] 

# Months (rows), Products (columns)

demand = [
    500 1000 300 300 800 200 100;
    600 500 200 0 400 300 150;
    300 600 0 0 500 400 100;
    200 300 400 500 200 0 100;
    0 100 500 100 1000 300 0;
    500 500 100 300 1100 500 60;
]

max_storage = 100

cost_storage = 0.5

end_storage = 50

# Help PARAMETERS
P = length(profit)
M = size(demand, 1)
I = size(available_time, 2)


###########################################

###########################################
# MODEL

FP = Model(Gurobi.Optimizer)

# Decision Variables
@variable(FP, 0 <= prod[1:M,1:P])
@variable(FP, 0 <= storage[1:M,1:P] <= max_storage)
@variable(FP, 0 <= sell[m=1:M,p=1:P] <= demand[m,p])
@variable(FP, 0 <= instrument[1:M,1:I,1:P])

# objective function
@objective(FP, Max, 
sum(sell[m,p] * profit[p] - storage[m,p] * cost_storage for m = 1:M, p = 1:P))

# constraints

# Total time per product for each month

@constraint(FP, [m=1:M, i=1:I], sum(instrument[m,i,p] for p=1:P) <= available_time[m,i])

# Production time for each product 
@constraint(FP,  [m=1:M,i=1:I,p=1:P], instrument[m,i,p] == prod[m,p] * process_time[i,p])

# Storage (ultimo)
@constraint(FP, [p=1:P], prod[1,p] - sell[1,p] == storage[1,p])
@constraint(FP, [m=2:M,p=1:P], storage[m-1,p] + prod[m,p] - sell[m,p] == storage[m,p])
@constraint(FP, [p=1:P], end_storage == storage[M,p])

###########################################

###########################################
# SOLVE
optimize!(FP)
println("Status: ", termination_status(FP))
println("Obj: ", objective_value(FP))
###########################################