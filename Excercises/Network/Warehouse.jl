using JuMP, Gurobi

#############################################
# PARAMETERS

# Arc costs
C = [
    0 0 0 4 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    3 0 0 0 0 9 0 8 0 9;
    0 0 8 0 5 0 0 0 0 0;
    0 0 0 0 0 0 0 0 7 0;
    0 0 0 0 0 0 0 0 3 0;
    8 1 0 0 0 0 0 0 0 0;
    0 0 0 3 0 0 0 0 0 5;
    7 0 0 0 0 0 0 0 0 6;
    0 0 0 0 0 0 7 0 0 0;
    ]

# Number of nodes
N = size(C, 1)

Demand = [30 30 50 0 20 30 30 40 0 20]

start_cost = [1000 1000 2000]

scenarios = 3

################################################
# MODEL
for s in 1:scenarios

    WH = Model(Gurobi.Optimizer)

    
    if s == 1
        Demand[4] = -250
    elseif s == 2
        Demand[9] = -250
        Demand[4] = 0
    elseif s == 3
        Demand[9] = 0
        Demand[4] = 0
    end

    # Decision variables
    @variable(WH, x[1:N,1:N] >= 0)

    for i in 1:N, j in 1:N
        if C[i,j] == 0
        fix(x[i,j], 0.0; force = true)
        end
    end


    # Objective
    if s == 3
        # If we uses warehouse 4 or 9
        @variable(WH, y[1:2], Bin)
        # Start quantity at ware house 4 and 9
        @variable(WH, q[1:2] >= 0)

        @constraint(WH, q[1] + q[2] == 250)
        @constraint(WH, q[1] <= 250 * y[1])
        @constraint(WH, q[2] <= 250 * y[2])

        for n in 1:N
            if n == 4
                @constraint(WH, sum(x[j,4] - x[4,j] for j=1:N) == -q[1])
            elseif n == 9
                @constraint(WH, sum(x[j,9] - x[9,j] for j=1:N) == -q[2])

            else
                @constraint(WH ,sum(x[j,n] - x[n,j] for j=1:N) == Demand[n])
            end
        end

        
        @objective(WH, Min, sum(x[i,j] * C[i,j] for i=1:N, j=1:N) + y[1]*1000 + y[2]*1000)

    else
        @objective(WH, Min, sum(x[i,j] * C[i,j] for i=1:N, j=1:N) + start_cost[s])
        @constraint(WH, [n=1:N] ,sum(x[j,n] - x[n,j] for j=1:N) == Demand[n])
    end

    # SOLVE
    optimize!(WH)
    if termination_status(WH) == MOI.OPTIMAL
        println("Optimal objective value for scenario $s: $(objective_value(WH))")
    else
        println("No optimal solution available")
    end    


end







