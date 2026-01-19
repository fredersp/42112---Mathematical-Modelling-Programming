using JuMP, Gurobi

Cost = [
    110 120 130 110 115;
    130 130 110  90 115;
    110 140 130 100  95;
    120 110 120 120 125;
    100 120 150 110 105;
     90 100 140  80 135;
]

Hardness = [8.8, 6.1, 2.0, 4.2, 5.0]
Price = 150.0
storage_cost = 5.0

Oil = ["VEG1","VEG2","OIL1","OIL2","OIL3"]
O = length(Oil)
M = size(Cost, 1)

BL = Model(Gurobi.Optimizer)

@variable(BL, buy[1:M,1:O] >= 0)
@variable(BL, use[1:M,1:O] >= 0)
@variable(BL, inv[1:M,1:O] >= 0, upper_bound=1000)

@objective(BL, Max,
    sum(Price * use[m,o] - Cost[m,o] * buy[m,o] - storage_cost * inv[m,o] for m=1:M, o=1:O)
)

# Refining capacities each month
@constraint(BL, [m=1:M], use[m,1] + use[m,2] <= 200)
@constraint(BL, [m=1:M], use[m,3] + use[m,4] + use[m,5] <= 250)

# Hardness per month
@constraint(BL, [m=1:M], sum(Hardness[o] * use[m,o] for o=1:O) >= 3 * sum(use[m,o] for o=1:O))
@constraint(BL, [m=1:M], sum(Hardness[o] * use[m,o] for o=1:O) <= 6 * sum(use[m,o] for o=1:O))

# Inventory flow with initial stock 500
@constraint(BL, [o=1:O], inv[1,o] == 500 + buy[1,o] - use[1,o])
@constraint(BL, [m=2:M, o=1:O], inv[m,o] == inv[m-1,o] + buy[m,o] - use[m,o])

# End stock same as start
@constraint(BL, [o=1:O], inv[M,o] == 500)

optimize!(BL)
println("Status: ", termination_status(BL))
println("Obj: ", objective_value(BL))
