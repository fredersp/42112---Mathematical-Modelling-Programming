#Santa's Workshop tour 2019
using JuMP, HiGHS

include("SantasWorkshopData_1000_20.jl")

#Parameters

#Model
SW = Model(HiGHS.Optimizer)

@variable(SW, x[1:F, 1:D], Bin)

@objective(SW, Min, sum(DayVisitCost[f,d]*x[f,d] for f=1:F, d=1:D))

@constraint(SW, [d=1:D], 125 <= sum(FamilySize[f] * x[f,d] for f=1:F)<=300)

@constraint(SW, [f=1:F], sum(x[f,d] for d=1:D)==1)

optimize!(SW)

println("Optimal objective value: $(objective_value(SW))")