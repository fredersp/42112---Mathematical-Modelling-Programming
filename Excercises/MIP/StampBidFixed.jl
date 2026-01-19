start_time=time_ns()

using JuMP, Gurobi

let

    ###################################################################
    # PARAMETERS AND DATA

    time_limit = 120
    K_initial = 500 #"Neighbourhood size"
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


    function FixAndOptimize(xVal,K)
        # first lock all variables to their values in current solution:
        for b=1:B
            fix(x[b], xVal[b]; force = true)
        end

        # then free K randomly chosen variables:
        free_vars=0
        while free_vars<K
            b=rand(1:B) #draw a random bid
            if is_fixed(x[b]) #if not already freed, free variable
                unfix(x[b])
                free_vars+=1
            end
        end

        optimize!(SB)
		
		#Extract new solution:
        xVal=round.(Int,value.(x))

        cur_obj=round(Int64,objective_value(SB))
        return (cur_obj,xVal)
    end

    println("Starting Fix and Optimize heuristic")
    cur_xVal=zeros(Int8,B) #Initial dummy solution: No bids are selected
   
    it=1
    cur_obj=-1
    old_obj=-1000000000000000
    this_time=(time_ns()-start_time)/1.0e9
    
    while this_time<time_limit
        (cur_obj,cur_xVal)=FixAndOptimize(cur_xVal,K)
        this_time=(time_ns()-start_time)/1.0e9
        println("It: $(it) Time: $(round(this_time,digits=1)) K: $(K) CurObj: $(cur_obj) "*
			"OldObj: $(old_obj)"*
			" Improvement: $(cur_obj-old_obj)")
        if cur_obj-old_obj < 0 #Maximization
			throw("Error. In iteration $it the current objective value $cur_obj "*
				"is lower than the old objective value $old_obj")
        end
		
		old_obj=cur_obj

        it+=1
    end
    #************************************************************************
    
    
    #************************************************************************
    println("Successfull end of $(PROGRAM_FILE)")
    #************************************************************************

end