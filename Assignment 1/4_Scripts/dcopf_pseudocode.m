
%% Load the appropriate matpower case file
%e.g. mpc = case3

%% Define your optimization variables
% Create the relevant vectors and assign them the appropriate size
% e.g P = sdpvar(5, 1)


%% Calculate the Bus Reactance Matrix B



%% Determine the objective function
%e.g. Objective = c*P



%% Determine the constraints 

constraints= [ 
        %equality constraints
        %inequality constraints
        %upper and lower bounds on optimization variables
                ]

            
%% Run the optimization
optimize(constraints, Objective)


%% Print the results
% e.g. value(P)

