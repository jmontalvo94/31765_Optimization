clc 
clear all
close all
%% Load the appropriate matpower case file with defined constants
define_constants
mpc = case4gs;

%% MATPOWER Case Format : Version 2
mpc.version = '2';
%% Change matrix size and set default variables in the matrixes
mpc.bus(4,:) = [];
mpc.branch(4,:) = [];

% Generator matrix initialize
mpc.gen(1,GEN_BUS) = 1;
mpc.gen(2,GEN_BUS) = 2;
for i = 1:2
        mpc.gen(i,PG) = 0;
        mpc.gen(i,QG) = 0;
        mpc.gen(i,QMAX) = 0;
        mpc.gen(i,QMIN) = 0;
        mpc.gen(i,VG) = 1;
        mpc.gen(i,PMAX) = 1;
end

% Bus matrix initialize
mpc.bus(1,BUS_TYPE) = 2;
mpc.bus(2,BUS_TYPE) = 2;
mpc.bus(3,BUS_TYPE) = 1;
for i = 1:3
        mpc.bus(i,PD) = 0;
        mpc.bus(i,QD) = 0;
end
mpc.bus(3,PD) = 150;

% Branch matrix initialize
mpc.branch(3,T_BUS) = 3;
for i = 1:3
        mpc.branch(i,BR_R) = 0;
        mpc.branch(i,BR_X) = 0;
        mpc.branch(i,BR_B) = 0;
        mpc.branch(i,RATE_A) = 0;
        mpc.branch(i,RATE_B) = 0;
        mpc.branch(i,RATE_C) = 0;
end

%% Define case study and initialize data
prompt = 'Which case study do you want to compute? (1, 2, 3, 4 or 5): ';
CS = input(prompt);

switch CS
    case 1
        mpc.gen(1,PMAX) = 100;
        mpc.gen(2,PMAX) = 200;
        for i = 1:3
            mpc.branch(i,RATE_A) = 10000;
        end
    case 2
        mpc.gen(1,PMAX) = 100;
        mpc.gen(2,PMAX) = 200;
        for i = 1:3
            mpc.branch(i,RATE_A) = 10000;
        end
    case 3
        mpc.gen(1,PMAX) = 100;
        mpc.gen(2,PMAX) = 200;
        mpc.branch(1,RATE_A) = 10000;
        mpc.branch(2,RATE_A) = 70;
        mpc.branch(3,RATE_A) = 10000;
    case 4
        mpc.gen(1,PMAX) = 100;
        mpc.gen(2,PMAX) = 200;
        mpc.branch(1,RATE_A) = 10000;
        mpc.branch(2,RATE_A) = 70;
        mpc.branch(3,RATE_A) = 10000;
        mpc.branch(1,BR_X) = 0.1;
        mpc.branch(2,BR_X) = 0.3;
        mpc.branch(3,BR_X) = 0.1;
    case 5
        mpc.gen(1,PMAX) = 100;
        mpc.gen(2,PMAX) = 200;
        mpc.branch(1,RATE_A) = 10000;
        mpc.branch(2,RATE_A) = 40;
        mpc.branch(3,RATE_A) = 10000;
        mpc.branch(1,BR_X) = 0.1;
        mpc.branch(2,BR_X) = 0.3;
        mpc.branch(3,BR_X) = 0.1;
end

%% Define your optimization variables
% Create the relevant vectors and assign them the appropriate size
delta= sdpvar(3,1);
c = [60,120];

P= [1/.1 *(delta(1)-delta(2))+1/.3*(delta(1) -delta(3));
    1/.1 *(delta(1)-delta(2))+1/.1*(delta(2) -delta(3))]*100

%% Calculate the Bus Susceptance Matrix B
B = zeros(3,3);
    for i=1:3
        for j=1:3
            %diagonal elements positive
            if i==j
                for k=1:3
                    if mpc.branch(k,F_BUS)==j || mpc.branch(k,T_BUS) == j
                        B(i,j) = B(i,j)+1/mpc.branch(k,BR_X);
                    end
                end
            else    
            %non-diagonal elements cero or negative
                for k=1:3
                    if (mpc.branch(k,F_BUS)==i && mpc.branch(k,T_BUS) == j) || (mpc.branch(k,F_BUS)==j && mpc.branch(k,T_BUS) == i)
                        B(i,j) = B(i,j)-1/mpc.branch(k,BR_X);
                    end
                end
            end  
        end
    end



%% Determine the objective function
Objective = c*P


%% Determine the constraints 
%equality constraints
Constraints = [(delta(1)-delta(3))/(1/.3)<=40/100, B*delta== [P(1)/100;P(2)/100;-mpc.bus(3,PD)/100]];
        
%upper and lower bounds on optimization variables
for i=1:2
    Constraints = [Constraints, mpc.gen(i,PMAX) >= P(i) >= mpc.gen(i,PMIN)];
end

            
%% Run the optimization
optimize(Constraints, Objective)


%% Print the results
 value(P)
 value(delta)
%ans = 70, 80

