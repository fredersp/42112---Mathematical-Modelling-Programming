using JuMP, Gurobi

#############################################
# PARAMETERS

# Earliest Arrival
EA = [125 187 94 99 111 123 129 131 142 155]
# Target Time
TT = [155 212 134 127 123 138 145 157 162 179]
# Latest Arrival
LA = [473 612 508 421 511 515 525 407 500 612]
# Penalty for not arriving at TT
PEN = [10 20 35 25 35 30 30 50 30 35]

# Seperation between arrivals
SEP = [
    0 5 15 15 15 15 15 10 15 5;
    5 0 15 15 10 15 10 15 15 15;
    15 15 0 10 15 10 15 10 15 10;
    15 15 10 0 10 10 10 15 15 15;
    15 10 15 10 0 10 5 10 15 5;
    15 15 10 10 10 0 15 15 15 15;
    15 10 15 10 5 15 0 10 5 10;
    10 15 10 15 10 15 10 0 10 15;
    15 15 15 15 15 15 5 10 0 10;
    5 15 10 15 5 15 10 15 10 0
]

# Number of airplanes
F = length(TT)
# Number of timeslots
K = size(SEP,1)

P = size(SEP,1)
Q = size(SEP,1)
M = 400 

###############################################
# MODEL
AS = Model(Gurobi.Optimizer)

@variable(AS, x[1:F], Int)
# Target time difference auxillary
@variable(AS, td[1:F], Int)
# Landing difference auxillary
@variable(AS, y[1:F,1:K], Bin)

# New auxillary, for seperation difference
@variable(AS, spt[1:P,1:Q])

#@objective(AS, Min, sum(td[f] * PEN[f] for f=1:F))
@objective(AS, Max, sum(spt[p,q] for p=1:P,q=1:Q))

# Constraints
@constraint(AS, [p=1:P,q=1:Q,k=1:K-1], 
            x[q] - x[p] + (2 - y[p,k] - y[q,k+1]) - SEP[q,p] <= spt[q,p])

@constraint(AS, [ q=1:Q,p=1:P,k=1:K-1], 
            x[p] - x[q] + (2 - y[q,k] - y[p,k+1]) - SEP[p,q] <= spt[p,q])
            
@constraint(AS, [f=1:F], EA[f] <= x[f] <= LA[f])

@constraint(AS, [f=1:F], td[f] >= x[f] - TT[f])
@constraint(AS, [f=1:F], td[f] >= -x[f] + TT[f])

# Make sure that each flight is delegated a timeslot and each timeslot is delegated a flight
@constraint(AS, [f=1:F], sum(y[f,k] for k=1:K) == 1)
@constraint(AS, [k=1:K], sum(y[f,k] for f=1:F) == 1)

#@constraint(AS, [p=1:P,q=1:Q,k=1:K-1], 
#            x[q] - x[p] + M * (2 - y[p,k] - y[q,k+1]) >= SEP[p,q])

@constraint(AS, [k=1:K-1], y[6,k] + y[5,k+1] <= 1)
@constraint(AS, [k=1:K-1], y[5,k] + y[6,k+1] <= 1)



##################################################

# SOLVE
optimize!(AS)


if termination_status(AS) == MOI.OPTIMAL
        println("Optimal objective value: $(objective_value(AS))")
        println("\nAircraft  times and slots:")
        for f=1:F, k=1:K
            if value(y[f,k]) > 0.5
                println("Aircraft $f lands at time $k")
            end
        end
    else
        println("No optimal solution available")
end
