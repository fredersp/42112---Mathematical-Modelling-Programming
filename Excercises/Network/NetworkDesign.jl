using Gurobi, JuMP

#############################################
# PARAMETERS

# Distance between ports
dist = [ 0.0 450.0 300.0 2200.0 6500.0 10500.0 19500.0 20000.0 16000.0 8800.0 6200.0
450.0 0.0 500.0 2400.0 6600.0 10700.0 19700.0 20200.0 16200.0 9000.0 6400.0
300.0 500.0 0.0 2100.0 6400.0 10400.0 19400.0 19900.0 15800.0 8600.0 6100.0
2200.0 2400.0 2100.0 0.0 5200.0 8500.0 16500.0 17000.0 15000.0 8200.0 6500.0
6500.0 6600.0 6400.0 5200.0 0.0 5800.0 10200.0 10800.0 13500.0 15000.0 11000.0
10500.0 10700.0 10400.0 8500.0 5800.0 0.0 3800.0 4600.0 14100.0 16700.0 15500.0
19500.0 19700.0 19400.0 16500.0 10200.0 3800.0 0.0 900.0 10400.0 12500.0 19000.0
20000.0 20200.0 19900.0 17000.0 10800.0 4600.0 900.0 0.0 9800.0 12000.0 18500.0
16000.0 16200.0 15800.0 15000.0 13500.0 14100.0 10400.0 9800.0 0.0 4800.0 6300.0
8800.0 9000.0 8600.0 8200.0 15000.0 16700.0 12500.0 12000.0 4800.0 0.0 3500.0
6200.0 6400.0 6100.0 6500.0 11000.0 15500.0 19000.0 18500.0 6300.0 3500.0 0.0]

# Number of ports
P = size(dist, 1)

cost1 = [10 6]

T = length(cost1)

cost2 = 0.01

cap = [800 400]

# Demand at each port
demand = [
# d1    d2    d3    d4    d5    d6    d7    d8
  0    400    0     0     0    440    0     0 ;   # 1 Rotterdam
 480     0     0     0     0     0    520    0 ;   # 2 Hamburg
  0      0    320    0     0     0     0     0 ;   # 3 Felixstowe
  0      0     0     0     0     0     0   -300;  # 4 Algeciras
  0      0   -320    0     0     0     0     0 ;   # 5 Jebel Ali
  0   -400    0     0    360    0     0     0 ;   # 6 Singapore
 -480    0     0    560    0     0     0     0 ;   # 7 Shanghai
  0      0     0     0     0     0     0    300;  # 8 Busan
  0      0     0     0     0     0   -520    0 ;   # 9 Los Angeles
  0      0     0     0   -360    0     0     0 ;   # 10 Panama
  0      0     0   -560    0   -440    0     0     # 11 New York
]

# Number of routes (commodities) 
K = size(demand,2)

##############################################
# MODEL
ND = Model(Gurobi.Optimizer)

# DECISION VARIABLES
# If route(p1,p2) is opened or not
@variable(ND, y[1:P,1:P,1:T], Bin)

# How much flows from p1 to p2 of different commodities
@variable(ND, f[1:P,1:P,1:K,1:T] >= 0)


# OBJECTIVE
@objective(ND, Min, sum(dist[p1,p2] * cost1[t] * y[p1,p2,t] for p1=1:P,p2=1:P,t=1:T) 
                    + sum(dist[p1,p2] * cost2 * f[p1,p2,k,t] for p1=1:P,p2=1:P,k=1:K,t=1:T))

# CONSTRAINTS
@constraint(ND, [p1=1:P,k=1:K], sum(f[p1,p2,k,t] for p2=1:P,t=1:T) - sum(f[p2,p1,k,t] for p2=1:P,t=1:T) 
                                == demand[p1,k])


@constraint(ND, [p1=1:P,p2=1:P,t=1:T], sum(f[p1,p2,k,t] for k=1:K) <= cap[t] * y[p1,p2,t])


@constraint(ND, [p1=1:P,t=1:T], sum(y[p1,p2,t] for p2=1:P) - sum(y[p2,p1,t] for p2=1:P) == 0)

#############################################
# SOLVE
optimize!(ND)
if termination_status(ND) == MOI.OPTIMAL
        println("Optimal objective value: $(objective_value(ND))")
    else
        println("No optimal solution available")
end    





