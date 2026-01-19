using JuMP, Gurobi

##########################################
# PARAMETERS

# Time for each person (rows) for each task (column)
time = [
 4.5 7.8 3.6 2.9;
 4.9 7.2 4.3 3.1;   
]

P = size(time, 1)
T = size(time, 2)

###########################################


###########################################
# MODEL
YC = Model(Gurobi.Optimizer)

@variable(YC, x[1:P,1:T], Bin)

@objective(YC, Min, sum(x[p,t] * time[p,t] for p=1:P, t=1:T))

@constraint(YC, [p=1:P], sum(x[p,t] for t=1:T) == 4)


optimize!(YC)

println("Status: ", termination_status(YC))
println("Finish time: ", value(s[last]))