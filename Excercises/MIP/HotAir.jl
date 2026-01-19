using JuMP, Gurobi

####################################################
# PARAMETERS
# Names and order of cities
cities = ["Brownsville", "Dallas", "Austin", "El Paso"]
# Number of time periods
T = 3
C = length(cities)

# Max passengers per plane
max_pas = 120

demand = zeros(Int16,T,C,C) # demand[timeperiod, city1, city2]

demand[1,:,:] = [
    0 50 53 14;
    84 0 80 21;
    17 58 0 40;
    31 79 34 0;
]

demand[2,:,:] = [
    0 15 53 52;
    17 0 134 29;
    24 128 0 99;
    23 15 30 0;

]

demand[3,:,:] = [
    0 3 16 9;
    48 0 104 48;
    62 92 0 68;
    13 15 21 0;
]

# Total cost per flight
cost = [
    0 5100 4400 8000;
    5100 0 11200 6900;
    4400 11200 0 5700;
    8000 6900 5700 0;
]
# Ticket prices
prices = [
    0 99 89 139;
    109 0 99 169;
    109 104 0 129;
    159 149 119 0;
]
# Number of overnight Hangars
Hangars = [2, 1, 1, 0]

######################################################

######################################################
# MODEL
HA = Model(Gurobi.Optimizer)

# DECISION VARIABLES
@variable(HA, 0 <= x[1:T,1:C,1:C], Int) # Number of passengers traveling from c1 to c2
@variable(HA, 0 <= y[1:T,1:C,1:C] <= 4, Int) # Number of planes from c1 to c2

# OBJECTIVE FUNCTION
@objective(HA, Max, sum(x[t,c1,c2] * prices[c1,c2] for t=1:T,c1=1:C,c2=1:C) - 
                    sum(y[t,c1,c2] * cost[c1,c2] for t=1:T,c1=1:C,c2=1:C))

# CONSTRAINTS
# Number of passengers is bounded by number of planes flying
@constraint(HA, [t=1:T,c1=1:C,c2=1:C], x[t,c1,c2] <= max_pas * y[t,c1,c2])

# Number og passengers is bounded by demand
@constraint(HA, [t=1:T,c1=1:C,c2=1:C], x[t,c1,c2] <= demand[t,c1,c2])

# Number of planes starting are bounded by hangar spots
#@constraint(HA, [c1=1:C], sum(y[1,c1,c2] for c2=1:C) <= Hangars[c1])

# Number of planes incoming must be equal to the plane leavings in timestep t+1
@constraint(HA, [t=1:T,c1=1:C], sum( y[t,c2,c1] for c2=1:C) == sum( (t<T ? y[t+1,c1,c2] : y[1,c1,c2]) for c2=1:C))

@constraint(HA, [t=1:T,c1=1:C,c2=1:C], y[t,c1,c2] * cost[c1,c2] <= x[t,c1,c2] * prices[c1,c2])


##################################################

# SOLVE
optimize!(HA)

if termination_status(HA) == MOI.OPTIMAL
        println("Optimal objective value: $(objective_value(HA))")
    else
        println("No optimal solution available")
end    



#####################################################################













