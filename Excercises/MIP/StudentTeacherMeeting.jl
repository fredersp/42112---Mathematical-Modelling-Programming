using JuMP, Gurobi

include("StudentTeacherMeetingData_15_6.jl")

#############################################
# PARAMETERS
# S: no of students : in data file
# T: no of teachers : in data file
# TS: no of timeslots : in data
println("Students: $(S) Teachers: $(T) Timeslots: $(TS)")
total_no_meetings=sum(StudentTeacherMeetings[:,:])
println("Total no. of meetings: $(total_no_meetings)")
#############################################

#############################################
# MODEL
STM = Model(Gurobi.Optimizer)

# 1 if student s has a meeting with teacher t in time ts
@variable(STM, x[1:S,1:T,1:TS],Bin)
# Remove irrelevant variables that will be zero anyways:
for s=1:S
    for t=1:T
      if StudentTeacherMeetings[s,t]==0
            for ts=1:TS
                fix(x[s,t,ts],0; force = true)
            end
        end
    end
end
# starting time of last meeting of student s
@variable(STM, y[1:S] >= 0)

# Minimize summed Inconvenience (how late to stay)

@objective(STM, Min, sum( y[s] for s=1:S ) )

# Constraints
@constraint(STM, [s=1:S,t=1:T], sum( x[s,t,ts] for ts=1:TS ) == StudentTeacherMeetings[s,t])

# at most one meeting pr timeslot for each student s
@constraint(STM, [s=1:S,ts=1:TS], sum( x[s,t,ts] for t=1:T ) <= 1)
# at most one meeting pr timeslot for each teacher t
@constraint(STM, [t=1:T,ts=1:TS], sum( x[s,t,ts] for s=1:S ) <= 1)
# force value of y to last meeting for each student
@constraint(STM, [s=1:S,ts=1:TS], ts*sum( x[s,t,ts] for t=1:T ) <= y[s])

########################################
# solve
optimize!(STM)
println("Termination status: $(termination_status(STM))")
