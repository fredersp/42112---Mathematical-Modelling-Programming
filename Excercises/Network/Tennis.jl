using JuMP, Gurobi

coords = [0 0;
          0 -39;
          4.5 0;
          4.5 -21;
          4.5 -39;
          18 0;
          18 -21;
          31.5 0;
          31.5 -21;
          31.5 -39;
          36 0;
          36 -39]

n = size(coords, 1)

# Euclidean distance matrix (walking distance)
dist = [hypot(coords[i,1] - coords[j,1], coords[i,2] - coords[j,2]) for i in 1:n, j in 1:n]

# REQUIRED segments: better store as undirected edges (a<b) to avoid duplicates
req_edges = Set{Tuple{Int,Int}}()
req_arcs = [
    (1,2), (2,1),(2,5), (5,2), (5,4), (4,5), (5,3), (3,5), (4,7),(7,4),(7,6),(6,7),
    (7,9),(9,7),(9,8),(8,9),(9,10),(10,9),(5,10), (10,5), (10,12), (12,10),(11,12),(12,11)
]
for (a,b) in req_arcs
    push!(req_edges, (min(a,b), max(a,b)))
end
req_edges = collect(req_edges)

TT = Model(Gurobi.Optimizer)

# x[i,j] = number of traversals i->j  (INTEGER, not binary)
@variable(TT, x[1:n, 1:n] >= 0, Int)

# y[i,j] = 1 if arc i->j used at least once (for subtour elimination)
@variable(TT, y[1:n, 1:n], Bin)

# forbid self loops
for i in 1:n
    @constraint(TT, x[i,i] == 0)
    @constraint(TT, y[i,i] == 0)
end

# link x and y (M can be n or larger; n is usually safe here)
M = n
@constraint(TT, [i=1:n, j=1:n], x[i,j] <= M * y[i,j])

# Objective: minimize total distance walked
@objective(TT, Min, sum(dist[i,j] * x[i,j] for i in 1:n, j in 1:n))

# Flow balance (closed walk): in-degree = out-degree
@constraint(TT, [i=1:n], sum(x[i,j] for j in 1:n) == sum(x[j,i] for j in 1:n))

# Cover every required court segment at least once (either direction)
@constraint(TT, [k in 1:length(req_edges)],
    x[req_edges[k][1], req_edges[k][2]] + x[req_edges[k][2], req_edges[k][1]] >= 1
)

# Connectivity: MTZ on y (prevents disconnected subtours)
@variable(TT, u[1:n] >= 1 <= n)
@constraint(TT, u[1] == 1)

@constraint(TT, [i=2:n], u[i] >= 2)  # optional, helps numerically

@constraint(TT, [i=2:n, j=2:n; i != j],
    u[i] - u[j] + (n-1) * y[i,j] <= n-2
)

optimize!(TT)

println("Objective: ", objective_value(TT))
for i in 1:n, j in 1:n
    if value(x[i,j]) > 0.5
        println("x[$i,$j] = ", value(x[i,j]))
    end
end
