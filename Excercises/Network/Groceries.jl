using JuMP, Gurobi, LinearAlgebra

#############################################
# PARAMETERS
using LinearAlgebra

# Names of locations
names = ["Grocery", "1", "2", "3", "4", "5"]

# Coordinates (rows correspond to names above)
coords = [
    0    0;
    104  19;
    370  305;
    651  221;
    112  121;
    134  515;
    797  424;
    347  444;
    756  141;
    304  351;
    236  775;
    687  310;
    452  57
]

# Number of locations
n = size(coords, 1)

# Initialize distance matrix
dist = zeros(n, n)

# Compute Euclidean distances
for i in 1:n
    for j in 1:n
        dist[i, j] = norm(coords[i, :] - coords[j, :])
    end
end

# Extra Parameters for assignment 15.3
Q = 26 # Total Capacity

q = [0 3 9 7 11 11 6 7 7 2 4 2 8]


###############################################
# MODEL
GR = Model(Gurobi.Optimizer)

# DECISION VARIABLES
@variable(GR, x[1:n,1:n], Bin)
@variable(GR, 0 <= u[1:n] <= Q )

# OBJECTIVE FUNCTION
@objective(GR, Min, sum(x[i,j] * dist[i,j] for i=1:n,j=1:n))

# CONSTRAINTS
# Change these to i=1:n if there is only 1 van
@constraint(GR, [i=2:n], sum(x[i,j] for j=1:n) == 1)
@constraint(GR, [i=2:n], sum(x[j,i] for j=1:n) == 1)
@constraint(GR, [i=1:n], sum(x[i,i]) == 0)


# Extra constraint for assingment 15.2, disallowing subtours
#@constraint(GR, [i=1:n,j=2:n], u[i] + 1 <= u[j] + n * (1- x[i,j]))

# Extra constraint for assingment 15.3, keep tracking of amounts delivered by each van
@constraint(GR, [i=1:n,j=2:n], u[i] + q[j] <= u[j] + Q * (1 - x[i,j]))

@constraint(GR, sum(x[1,j] for j=1:n) == 3)
@constraint(GR, sum(x[i,1] for i=1:n) == 3)

##################################################

# SOLVE
optimize!(GR)
if termination_status(GR) == MOI.OPTIMAL
        println("Optimal objective value: $(objective_value(GR))")
    else
        println("No optimal solution available")
end    












