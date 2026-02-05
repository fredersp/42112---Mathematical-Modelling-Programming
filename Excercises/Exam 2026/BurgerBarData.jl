Employees = ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L"]  # list of employees
E=length(Employees)
Days = ["Mon" "Tue" "Wed" "Thur" "Fri" "Sat" "Sun"]
D=length(Days)
Hours= ["16-17" "17-18" "18-19" "19-20" "20-21" "21-22"]
H=length(Hours)

WorkerDemand=[ # WorkerDemand[day,hour]: no of needed workers
1 2 4 4 4 3;
1 2 2 4 4 3;
1 2 2 4 4 2;
2 2 3 3 4 3;
2 3 5 5 6 6;
4 5 5 6 6 6;
5 5 6 6 4 4 ]

Target = [8 8 8 10 10 10 15 15 20 20 20 20]
