using JuMP, Gurobi
using Graphs, GraphPlot, Cairo


#############################################
# PARAMETERS
# Arc costs
c= [ 0.0 450.0 300.0 2200.0 6500.0 10500.0 19500.0 20000.0 16000.0 8800.0 6200.0
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

# Connection and their costs
arcs_limit = [
    800 800 800 800 800 800 800 800 800 800 800;
    800 800 800 800 800 800 800 800 800 800 800;
    800 800 800 800 800 800 800 800 800 800 800;
    800 800 800 800 800 800 800 800 800 800 800;
    800 800 800 800 800 800 800 800 800 800 800;
    800 800 800 800 800 800 800 800 800 800 800;
    800 800 800 800 800 800 800 800 800 800 800;
    800 800 800 800 800 800 800 800 800 800 800;
    800 800 800 800 800 800 800 800 800 800 800;
    800 800 800 800 800 800 800 800 800 800 800;
    800 800 800 800 800 800 800 800 800 800 800;
]

# Number of ports
N = size(arcs_limit, 1)

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

K = size(demand, 2)  # Number of container types
S = 2

###########################################

#############################################
# MODEL
CS = Model(Gurobi.Optimizer)

# Decision variables
@variable(CS, 0 <= x[1:N,1:N,1:K,1:S])
@variable(CS,  y[1:N,1:N,1:S], Bin)

for i in 1:N, j in 1:N, k in 1:K, s in 1:S
        if arcs_limit[i,j] == 0
        fix(x[i,j,k,s], 0.0; force = true)
        end
    end

@objective(CS, Min, sum(0.01 * c[i,j] * x[i,j,k,s] for i=1:N, j=1:N, k=1:K, s=1:S) + sum(y[i,j,1]*10*c[i,j] for i=1:N,j=1:N) 
+ sum(y[i,j,2]*6*c[i,j] for i=1:N,j=1:N))

@constraint(CS, [n=1:N, k=1:K], sum(x[i,n,k,s] for i=1:N, s=1:S) - sum(x[n,j,k,s] for j=1:N, s=1:S) == -demand[n,k])

@constraint(CS, [i=1:N,j=1:N], sum(x[i,j,k,s] for k=1:K, s=1:S) <= arcs_limit[i,j] * y[i,j,1] + (arcs_limit[i,j]/2) * y[i,j,2])

@constraint(CS, [n=1:N,s=1:S], sum(y[n,j,s] for j=1:N) - sum(y[i,n,s] for i=1:N) == 0)


@constraint(CS, [i=1:N, j=1:N], y[i,j,1] + y[i,j,2] <= 1)


# SOLVE
optimize!(CS)
if termination_status(CS) == MOI.OPTIMAL
        println("Optimal objective value: $(objective_value(CS))")
    else
        println("No optimal solution available")
end    

# # --- Build graph of opened arcs ---
# g = DiGraph(N)

# opened = Tuple{Int,Int}[]
# for i in 1:N, j in 1:N
#     if i != j && value(y[i,j]) > 0.5
#         add_edge!(g, i, j)
#         push!(opened, (i,j))
#     end
# end

# edge_weights = Float64[]
# for e in edges(g)
#     i, j = src(e), dst(e)
#     push!(edge_weights, sum(value(x[i,j,k]) for k in 1:K))
# end

# # Avoid divide-by-zero if all flows happen to be 0 (shouldn't, but safe)
# maxw = isempty(edge_weights) ? 1.0 : maximum(edge_weights)

# gplot(g,
#     nodelabel = 1:N,
#     edgelinewidth = (edge_weights ./ maxw) .* 4,   # thickness scale
#     arrowlengthfrac = 0.02
# )

# portnames = ["Rotterdam","Hamburg","Felixstowe","Algeciras","Jebel Ali",
#              "Singapore","Shanghai","Busan","Los Angeles","Panama","New York"]

# gplot(g,
#     nodelabel = portnames,
#     edgelinewidth = (edge_weights ./ maxw) .* 4,
#     arrowlengthfrac = 0.02
# )

# println("\n--- Arc flows (total TEU/week) ---")
# for e in edges(g)
#     i, j = src(e), dst(e)
#     tot = sum(value(x[i,j,k]) for k in 1:K)
#     if tot > 1e-6
#         println("$(portnames[i]) → $(portnames[j]) : ", round(tot, digits=2))
#     end
# end
