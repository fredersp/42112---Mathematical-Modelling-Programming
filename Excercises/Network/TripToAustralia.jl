using JuMP, Gurobi

#############################################
# PARAMETERS
# List of city names in correct order
Cities = ["CPH" "DXB" "FRA" "SIN" "DOH" "SYD"]

# Cost matrix between cities, 0 represent no connection
C = [
    0 6 2 0 0 0;
    0 0 0 5 2 0;
    0 5 0 2 5 0;
    0 0 0 0 0 5;
    0 0 0 6 0 10;
    0 0 0 0 0 0;
    ]


I = length(Cities)
J = length(Cities)

###############################################

###############################################
# MODEL
TTA = Model(Gurobi.Optimizer)

# DECISION VARIABLES
@variable(TTA, x[1:I,1:J] >= 0)

# Make sure we don't use variables with no arcs
for i in 1:I, j in 1:J
    if C[i,j] == 0
        fix(x[i,j], 0.0; force = true)
    end
end

# OBJECTIVE
@objective(TTA, Min, sum(x[i,j] * C[i,j]*100 for i=1:I, j=1:J))

# CONSTRAINTS
@constraint(TTA, sum(x[1,j] for j=1:J) - sum(x[i,1] for i=1:I) == 1)

@constraint(TTA, sum(x[6,j] for j=1:J) - sum(x[i,6] for i=1:J) == -1)

for v in 1:I
    if v != 1 && v != 6
        @constraint(TTA, sum(x[v,j] for j=1:J) == sum(x[i,v] for i=1:I))
    end
end

##############################################

##############################################
# SOLVE
optimize!(TTA)
if termination_status(TTA) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(TTA))")
else
    println("No optimal solution available")
end


