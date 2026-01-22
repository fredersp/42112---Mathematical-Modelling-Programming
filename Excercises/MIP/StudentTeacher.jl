using Gurobi, JuMP

##########################################
# PARAMETERS
include("StudentTeacherMeetingData_15_6.jl")

##########################################

##########################################
# MODEL
STM = Model(Gurobi.Optimizer)

@variable(STM, x[1:S,1:T,1:TS], Bin)
@variable(STM, f[1:S] >= 0)

@objective(STM, Min, sum(f[s] for s=1:S))

@constraint(STM, [t=1:T,ts=1:TS], sum(x[s,t,ts] for s=1:S) <= 1)


@constraint(STM, [s=1:S,t=1:T;StudentTeacherMeetings[s,t] == 1], sum(x[s,t,ts] for ts=1:TS) == 1)

@constraint(STM, [s=1:S,ts=1:TS], ts * sum(x[s,t,ts] for t=1:T) <= f[s])

################################################
# SOLVE

optimize!(STM)
println("Optimal objective value: $(objective_value(STM))")




