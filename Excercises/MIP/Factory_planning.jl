#Factory Planning
using JuMP, GLPK

#Parameters

Profit = [10 6 8 4 11 9 3]



Process_Time = [0.50 0.70 0 0 0.30 0.20 0.50;
                0.10 0.20 0 0.30 0 0.60 0;
                0.20 0 0.80 0 0 0 0.60;
                0.05 0.03 0 0.070 0.10 0 0.08;
                0 0 0.01 0 0.05 0 0.05;
                ]

# 4 grinders, 2 vert. drills, 3 h. drills, 1 borer, 1 planer
#Months = rows, Machines = columns
Available_time_month  = 16*24*[3 2 3 1 1;
                                4 2 1 1 1;
                                4 2 3 0 1;
                                4 1 3 1 1;
                                3 1 3 1 1;
                                4 2 2 1 0;] #in hours]   

#month = rows, product = columns                              
Demand = [500 1000 300 300 800 200 100;
            600 500 200 0 400 300 150;
            300 600 0 0 500 400 100;
            200 300 400 500 200 0 100;
            0 100 500 100 1000 300 0;
            500 500 100 300 1100 500 60;
            ]

Max_storage = 100 #pr month pr product
Cost_storage = 0.5 #pr unit pr month
End_storage = 50 #pr product

M = size(Demand, 1) #Months
P = length(Profit) #Product (1-7)
I = size(Process_Time, 1) #Machines

#Model
FP = Model(GLPK.Optimizer)

@variable(FP, prod[m=1:M, p=1:P] >= 0)
@variable(FP, 0 <= storage[m=1:M, p=1:P] <= Max_storage)
@variable(FP, 0 <= sell[m=1:M, p=1:P] <= Demand[m,p])
@variable(FP, instrument[m=1:M, i=1:I, p=1:P] >=0)

@objective(FP, Max, sum(sell[m,p]*Profit[p] - Cost_storage * storage[m,p] for m=1:M, p=1:P))

### constraints

#Constraint for available time each month
@constraint(FP, [m = 1:M, i=1:I], sum(instrument[m,i,p] for p=1:P) <= Available_time_month[m,i])
#constraint for production time for each product
@constraint(FP, [m=1:M, i=1:I, p=1:P], instrument[m,i,p] == Process_Time[i,p] * prod[m,p])

#Storage constraints (Ultimo)
@constraint(FP, [m=1:M, p=1:P], prod[m,p] - sell[m,p] + (m>1 ? storage[m-1,p] : 0) == storage[m,p])

@constraint(FP, [p=1:P], storage[6,p] == End_storage)
@constraint(FP, [m=1:M, p=1:P], sell[m,p] <= Demand[m,p])


#Solve

optimize!(FP)
println("Objective", objective_value(FP))
#Print prod
for m=1:M
    println("Month ", m)
    for p=1:P
        println("Product ", p, ": Produced ", value(prod[m,p]), " Sold: ", value(sell[m,p]), " Stored: ", value(storage[m,p]))
    end
end
