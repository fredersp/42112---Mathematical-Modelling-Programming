#Startup fund
using JuMP, HiGHS

#Parameters

#Rows = Person, Columns = tasks
EP = [29 35 24 52 53 41 43 68 28]

Cost = [17 25 19 25 28 23 29 31 18]


J = length(EP)



#Model

SF = Model(HiGHS.Optimizer)

@variable(SF, x[1:J], Bin)

@objective(SF, Max, sum(EP[j]*x[j] for j=1:J))

@constraint(SF, sum(x[j]*Cost[j] for j=1:J)<= 100)

@constraint(SF, x[1] + x[5]<=1)
@constraint(SF, x[2] + x[3] >= x[6])
@constraint(SF, x[2] + x[3] >= x[9])



optimize!(SF)
println("Objective value: $(objective_value(SF))")

