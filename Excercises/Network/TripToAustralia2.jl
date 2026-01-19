using JuMP, Gurobi

#############################################
# PARAMETERS
# List of city names in correct order
Cities = ["CPH" "DXB" "FRA" "SIN" "DOH" "SYD"]


arcs = [("CPH","DXB"), ("CPH","FRA"), 
("DXB","SIN"), ("DXB","DOH"),
("FRA","DXB"), ("FRA","SIN"), ("FRA","DOH"),
("SIN","SYD"),
("DOH","SIN"), ("DOH","SYD")]

# Cost matrix between cities, 0 represent no connection
C = Dict{Tuple{Int,Int}, Int}()
C[("CPH","DXB")] = 6
C[("CPH","FRA")] = 2 
C[("DXB","SIN")] = 5
C[("DXB","DOH")] = 2
C[("FRA","DXB")] = 5
C[("FRA","SIN")] = 2
C[("FRA","DOH")] = 5
C[("SIN","SYD")] = 5
C[("DOH","SIN")] = 6
C[("DOH","SYD")] = 10

CPH = 1
SYD = 6

###############################################

###############################################
# MODEL
TTA = Model(Gurobi.Optimizer)

# DECISION VARIABLES
@variable(TTA, x[a in arcs] >= 0)



# OBJECTIVE
@objective(TTA, Min, sum(x[a] * C[a]*100 for a in arcs))

# CONSTRAINTS
@constraint(TTA, sum(x[a] for a in arcs if a[1] == CPH) -
                sum(x[a] for a in arcs if a[2] == CPH) == 1)

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


