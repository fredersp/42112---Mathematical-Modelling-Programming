#Young couple
using JuMP, HiGHS

#Parameters

#Rows = Person, Columns = tasks
Tasks = [4.5 7.8 3.6 2.9;
        4.9 7.2 4.3 3.1;]


I = size(Tasks, 1)
J = size(Tasks, 2)

#Model

YC = Model(HiGHS.Optimizer)

@variable(YC, x[1:I, 1:J], Bin)

@objective(YC, Min, sum(x[i,j] * Tasks[i,j] for i=1:I, j=1:J))

#@constraint(YC, sum(x[i,j] for j=1:J, i=1:I) == 4)
@constraint(YC, [j=1:J], sum(x[i,j] for i=1:I)==1)
@constraint(YC, [i=1:I], sum(x[i,j] for j=1:J)==2)


optimize!(YC)
println("Objective value: $(objective_value(YC))")
#print xij
for i=1:I
    for j=1:J
        println("x[", i, ",", j, "] : ", value(x[i,j]))
    end
end
