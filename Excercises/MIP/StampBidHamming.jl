start_time=time_ns()

using JuMP, Gurobi

let

    ###################################################################
    # PARAMETERS AND DATA

    time_limit = 120
    K_initial = 2 #"Neighbourhood size"
    K = K_initial 

    include("bid_data_400_2000.jl")

    B = length(BidPrice)

    S = size(BidSets, 2)

    #Model

    SB = Model(Gurobi.Optimizer)
    set_silent(SB) #To not get print from solver

     #Set timelimit pr MP solve to less than full timelimit

    set_time_limit_sec(SB, time_limit/2) 


    @variable(SB, x[1:B], Bin)

    @objective(SB, Max, sum(x[b] * BidPrice[b] for b in 1:B))

    @constraint(SB, [s=1:S], sum(BidSets[b,s] * x[b] for b=1:B) <= 1)


    #Function to add constraint that forces new solution and solves model again:
    function AddKConstraintAndOptimize(xVal,K)

        @constraint(SB, Kconstraint,
                    sum( x[b] for b=1:B if xVal[b]==0) +
                        sum( (1-x[b]) for b=1:B if xVal[b]==1)
                    <= K)

        optimize!(SB)
        #Extract infromation on the new solution:
        xVal=round.(Int,value.(x))
        #slackVal=round.(Int,value.(slack))
        curObj=round(Int64,objective_value(SB))
        
        #Remove the newly added constraint from the model after use:
        delete(SB, Kconstraint)
        unregister(SB, :Kconstraint)
        
        return (curObj,xVal)
    end

    println("Starting Hamming Distance Heuristic")
    xVal=zeros(Int8,B) #Start with empty solution, NO bids are selected
    it=1
    curObj=-1
    oldObj=-1

    while (time_ns()-start_time)/1.0e9<time_limit
        (curObj,xVal)=AddKConstraintAndOptimize(xVal,K)
        this_time=(time_ns()-start_time)/1.0e9
        println("It: $(it) Time: $(round(this_time,digits=1)) K: $(K) "*
                "CurObj: $(curObj)")
        if curObj<=oldObj # comparison for maximization problems
            K=K+1 #If no improvement, increase neighbourhood.
        else
            K=K_initial #If there IS improvement then search with small neighbourhood for as long as possible
        end
        oldObj=curObj
        it+=1
    end
    #************************************************************************

    #************************************************************************
    println("Successfull end of $(PROGRAM_FILE)")
    #************************************************************************

end