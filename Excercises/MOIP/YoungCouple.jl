using JuMP, Gurobi, MultiObjectiveAlgorithms

##########################################
# PARAMETERS

# Time for each person (rows) for each task (column)
time = [
 4.5 7.8 3.6 2.9 1.1 2.1 1.9;
 4.9 7.2 4.3 3.1 2.3 1.5 3.2;   
]

P = size(time, 1)
T = size(time, 2)

###########################################


###########################################
# MODEL
YC = Model(Gurobi.Optimizer)

@variable(YC, x[1:P,1:T], Bin)

@variable(YC, td >= 0)

@expression(YC, totalTime, sum(x[p,t] * time[p,t] for p=1:P, t=1:T))

@expression(YC, timeDiff, sum(td))

@constraint(YC, [t=1:T], sum(x[p,t] for p=1:P) == 1)

@constraint(YC, sum(x[1,t] * time[1,t] for t=1:T) - sum(x[2,t] * time[2,t] for t=1:T) <= td)

@constraint(YC, sum(x[2,t] * time[2,t] for t=1:T) - sum(x[1,t] * time[1,t] for t=1:T) <= td)


@objective(YC, Min, [totalTime, timeDiff])

set_optimizer(YC, () -> MultiObjectiveAlgorithms.Optimizer(Gurobi.Optimizer))
set_silent(YC)

set_attribute(YC, MultiObjectiveAlgorithms.Algorithm(), MultiObjectiveAlgorithms.EpsilonConstraint())

optimize!(YC)

worktime = [0 0 0 0]

# Solution
if result_count(YC) >= 1
    println("Pareto optimal points: ", result_count(YC))
    for i in 1:result_count(YC)
        local y = objective_value(YC; result = i)
        worktime[i] = sum(value(x[1,t] * time[1,t]) for t=1:T)
        println("Objective 1: ", round(y[1], digits = 1), " Objective 2: ", round(y[2], digits = 1))
        println("Total worktime for Eve: ", worktime[i])
    end
else
    println("No solutions found")
end
