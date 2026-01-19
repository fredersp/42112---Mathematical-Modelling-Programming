using JuMP, Gurobi

##########################################
# PARAMETERS

# Linkage matrix
linkage = [
    0 0 0 0 0 0 0 0 0 0 0 0 0;
    1 0 0 0 0 0 0 0 0 0 0 0 0;
    0 1 0 0 0 0 0 0 0 0 0 0 0;
    0 1 0 0 0 0 0 0 0 0 0 0 0;
    0 0 1 1 0 0 0 0 0 0 0 0 0;
    0 0 1 1 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 1 0 0 0 0 0 0 0;
    0 0 0 0 0 0 1 0 0 0 0 0 0;
    0 0 0 0 0 0 1 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 1 0 0 0 0;
    0 0 0 0 0 0 0 0 1 0 0 0 0;
    0 0 0 0 0 0 0 0 1 0 0 0 0;
    0 0 0 0 0 0 0 1 1 1 1 1 0;
]

# Duration of tasks
duration = [1 3 5 3 7 4 3 1 1 1 3 1 0]


###########################################

###########################################
# MODEL

N = length(duration)
last = 13

model = Model(Gurobi.Optimizer)

@variable(model, s[1:N] >= 0)


# precedence constraints
for j in 1:N, i in 1:N
    if linkage[j,i] == 1
        @constraint(model, s[j] >= s[i] + duration[i])
    end
end

@objective(model, Min, s[last])

optimize!(model)

println("Status: ", termination_status(model))
println("Finish time: ", value(s[last]))