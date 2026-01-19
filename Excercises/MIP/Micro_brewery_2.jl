#Micro brewery 2
using JuMP, HiGHS

#Parameters
Time = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
T = length(Time)


Cost = 0.1
#Columns: 1: TSP-stout, 2: Knapsack, 3: Set-Partitioning
Demand = [35 15 5;
            20 10 20;
            15 20 20;
            45 15 35;
            25 15 35;
            65 55 80;
            40 90 60;
            50 80 30;
            35 25 35;
            85 45 20;
            50 5 20;
            55 30 40;]


B = size(Demand, 2)

Starting_storage = [25 65 75]

#Model
MB = Model(HiGHS.Optimizer)

@variable(MB, 0 <= p[1:T, 1:B], Int)
@variable(MB, 0 <= s[1:T, 1:B], Int)
@variable(MB, x[1:T, 1:B], Bin)

@objective(MB, Min, sum(Cost * s[t, b] for t = 1:T, b = 1:B))

#Capacity constraint
@constraint(MB, [t=1:T, b=1:B], p[t,b] <= 120*x[t,b])
@constraint(MB, [t=1:T], sum(x[t,b] for b = 1:B) <= 1)

#Storage constraints
@constraint(MB, [t=1:T], sum(s[t,b] for b = 1:B) <= 300)
@constraint(MB, [t=2:T, b=1:B], p[t,b] + s[t-1,b] - Demand[t,b] >= 0)
#demand for first month
#@constraint(MB, [b=1:B], p[1,b] + s[1,b] - Demand[1,b] >= 0)
#Storage update
@constraint(MB, [t=2:T, b=1:B], p[t,b] + s[t-1,b] - Demand[t,b] - s[t,b] == 0)

#Starting constraints
@constraint(MB, [b=1:B], s[1,b]==Starting_storage[b] + p[1,b] - Demand[1,b])

#Solve

optimize!(MB)
println("Optimal objective value: $(objective_value(MB))")

#Print production 
for t in 1:T
    for b in 1:B
        println("Production at time $t for beer $b: ", value(p[t,b]))
    end
end

#print sum of storage
for t in 1:T
    for b in 1:B
        println("Storage at time $t for beer $b: ", sum(value(s[t,b])))
    end
end