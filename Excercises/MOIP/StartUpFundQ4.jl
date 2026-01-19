# MOIP: Startup Fund Q4
using JuMP, Gurobi
using MultiObjectiveAlgorithms

############################################################
# PARAMETERS

EP = [29 35 24 52 53 41 43 68 28] # Expected profit

Cost = [17 25 19 25 28 23 29 31 18] # Cost

sdg = [8 6 8 3 4 5 3 2 7] # SDG score

J = length(EP)

#############################################################
# MODEL

SF = Model()

@variable(SF, x[1:J], Bin)

@expression(SF, profit, sum(EP[j]*x[j] for j=1:J))
@expression(SF, sdg_score, sum(sdg[j] * x[j] for j=1:J))

@objective(SF, Max, [profit, sdg_score])



@constraint(SF, sum(x[j]*Cost[j] for j=1:J)<= 100)


set_optimizer(SF, () -> MultiObjectiveAlgorithms.Optimizer(Gurobi.Optimizer))
set_silent(SF)

set_attribute(SF, MultiObjectiveAlgorithms.Algorithm(), MultiObjectiveAlgorithms.EpsilonConstraint())

optimize!(SF)

# Solution
if result_count(SF) >= 1
    println("Pareto optimal points: ", result_count(SF))
    for i in 1:result_count(SF)
        y = objective_value(SF; result = i)
        println("Objective 1: ", round(Int, y[1]), " Objective 2: ", round(Int, y[2]))
    end
else
    println("No solutions found")
end
