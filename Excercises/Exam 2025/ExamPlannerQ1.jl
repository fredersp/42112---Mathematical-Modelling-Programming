# Exam Planning - Q1
using HiGHS, JuMP

#################################################
# PARAMETERS
include("ExamPlanningData.jl")

#################################################

#################################################
# MODEL 
EP = Model(HiGHS.Optimizer)

# DECISION VARIABLES
@variable(EP, x[1:E,1:R,1:T], Bin) # Binary allocating exams to rooms and timeslots
@variable(EP, f[1:R,1:T], Bin) # Helper variable keeping track of exams in same room same timeslot

# OBJECTIVE 
@objective(EP, Min, sum(f[r,t] * RoomCost[r,t] for r=1:R,t=1:T) + 
sum(x[e,r,t] * ExamTimeslotPenalty[e,t] for e=1:E,r=1:R,t=1:T) +
sum(x[e,r,t] * ExamRoomPenalty[e,r] for e=1:E,r=1:R,t=1:T))

# CONSTRAINTS
# Each exam must be alloacted
@constraint(EP, [e=1:E], sum(x[e,r,t] for r=1:R,t=1:T) == 1) 

# Enforce max cap of the room
@constraint(EP, [r=1:R,t=1:T], sum(x[e,r,t] * ExamStudents[e] for e=1:E) <= RoomCap[r])

# Make sure that we add cost
@constraint(EP, [e=1:E,r=1:R,t=1:T], f[r,t] >= x[e,r,t])

##########################################################
# SOLVE

optimize!(EP)
println("Objective", objective_value(EP))