clear
close all
clc
define_constants
%% Load the appropriate matpower case file
mpc = case9_SDP;

%% Initialize variables and matrices
% Buses
N = size(mpc.bus,1);

% Generators
G = size(mpc.gen,1);

% Lines
L = size(mpc.branch,1);

% Add resistance to transformers/lines -> connected resistive graph
for i = 1:L
    if mpc.branch(i,BR_R) == 0
        mpc.branch(i,BR_R) = 0.0001;
    end
end

% Ask about setting the slack bus angle to 0
prompt = 'Do you want to set the slack bus angle to 0? (0=no or 1=yes): ';
slack = input(prompt);

%% Define your optimization variables
% Create the relevant vectors/matrices and assign them the appropriate size
W = sdpvar(2*N,2*N);
alfa_k = sdpvar(G,1);

if slack==1
    W(:,N+1)=0;
    W(N+1,:)=0;
end

%% Calculate auxiliary variables
[Y_k,Y_k_,M_k,Y_lm,Ylinetf,Y_lm_,Y_linetf,Y_l,Y_l_] = makesdpmat(mpc);

%% Determine the objective function
Objective = sum(alfa_k,1);

%% Determine the constraints 
Constraints = []; 
      
        %active and reactive power balance
        for k=1:G
            Constraints = [Constraints, mpc.gen(k,PMIN)/100 - mpc.bus(k,PD)/100 <= trace(Y_k(k)*W) <= mpc.gen(k,PMAX)/100 - mpc.bus(k,PD)/100];
            Constraints = [Constraints, mpc.gen(k,QMIN)/100 - mpc.bus(k,QD)/100 <= trace(Y_k_(k)*W) <= mpc.gen(k,QMAX)/100 - mpc.bus(k,QD)/100];
        end
        for k=G+1:N
            Constraints = [Constraints, - mpc.bus(k,PD)/100 <= trace(Y_k(k)*W) <= - mpc.bus(k,PD)/100];
            Constraints = [Constraints, - mpc.bus(k,QD)/100 <= trace(Y_k_(k)*W) <= - mpc.bus(k,QD)/100];
        end
        
        %bus voltages
        for k=1:N
            Constraints = [Constraints, (mpc.bus(k,VMIN))^2 <= trace(M_k(k)*W) <= (mpc.bus(k,VMAX))^2];
        end
        
        %active branch flows
        for lm=1:L
            Constraints = [Constraints, -mpc.branch(lm,RATE_A)/100 <= trace(Y_lm(lm)*W) <= mpc.branch(lm,RATE_A)/100];
        end
        
        %objective semidefinite
        for k=1:G
        Constraints = [Constraints, [mpc.gencost(k,6)*1e2*trace(Y_k(k)*W) - alfa_k(k,1) + mpc.gencost(k,7) + mpc.gencost(k,6)*1e2*(mpc.bus(k,PD)/100),...
                                     sqrt(mpc.gencost(k,5)*1e4)*trace(Y_k(k)*W) + sqrt(mpc.gencost(k,5)*1e4)*(mpc.bus(k,PD)/100) ;...
                                     sqrt(mpc.gencost(k,5)*1e4)*trace(Y_k(k)*W) + sqrt(mpc.gencost(k,5)*1e4)*(mpc.bus(k,PD)/100), ...
                                     -1] <= 0];
        end
        
        %apparent line flows semidefinite
        for lm=1:L
            Constraints = [Constraints, [-(mpc.branch(lm,RATE_A)/100)^2, trace(Y_lm(lm)*W), trace(Y_lm_(lm)*W);...
                                        trace(Y_lm(lm)*W), -1, 0;...
                                        trace(Y_lm_(lm)*W), 0, -1] <= 0];
        end
        
        %W semidefinite
        Constraints = [Constraints, W >= 0];
           
%% Run the optimization
optimize(Constraints, Objective)

%% Print the results
% Calculate active and reactive power injections
for k=1:N
    P(k,1)=trace(Y_k(k)*W)*100;
    Q(k,1)=trace(Y_k_(k)*W)*100;
end

nonconvex_results = runopf(mpc);

% Compare to non-convex AC-OPF results


disp('Objective Function Value from Non-convex AC-OPF')
nonconvex_objective = nonconvex_results.f
disp('Objective Function Value from SDP')
display(value(sum(alfa_k,1)));


disp('Active Power Injections from Non-convex AC-OPF')
solverP = nonconvex_results.gen(:,PG)
disp('Active Power from SDP')
display(value(P));

disp('Reactive Power Injections from Non-convex AC-OPF')
solverQ = nonconvex_results.gen(:,QG)
disp('Reactive Power from SDP')
display(value(Q));

%% Post-process
% eig(A) might be helpful to calculate eigenvalues and -vectors of matrix A
lambda=value(eig(W));
lambda=sort(lambda,'descend');

if slack==1

    % Calculate eigenvalue ratio and evaluate exactness of the relaxation
    scatter(1:2*N, lambda(:,1),'filled')
    xlabel('Eigenvalue Index')
    ylabel('Eigenvalue')
    ratio=lambda(1)/lambda(2);

    % Decompose W matrix to obtain optimal voltage vector

    %only using the highest eigenvalue
    [V,D] = eig(value(W));
    X_opt = sqrt(lambda(1))*V(:,2*N);
    
    for i=1:N
        voltage(i,1)=complex(X_opt(i),X_opt(i+N));
        voltageM(i,1)=abs(voltage(i));
        voltageA(i,1)=rad2deg(angle(voltage(i)));
        if voltageA(i,1)>0
            voltageA(i,1)=voltageA(i,1)-180;
        else
            voltageA(i,1)=voltageA(i,1)+180;
        end
    end
    
else

    % Calculate eigenvalue ratio and evaluate exactness of the relaxation
    scatter(1:2*N, lambda(:,1),'filled')
    xlabel('Eigenvalue Index')
    ylabel('Eigenvalue')
    ratio=lambda(2)/lambda(3);    

    % Decompose W matrix to obtain optimal voltage vector

    %using two eigenvalues
    [V,D] = eig(value(W));
    X_opt = sqrt(lambda(1))*V(:,2*N)+sqrt(lambda(2))*V(:,2*N-1);
    
    for i=1:N
        voltage(i,1)=complex(X_opt(i),X_opt(i+N));
        voltageM(i,1)=abs(voltage(i));
        voltageA(i,1)=rad2deg(angle(voltage(i)));
    end
    
end

disp('Complex Voltage Vector from SDP')
display(value(voltage))
disp('Voltage Magnitudes Vector from SDP')
display(value(voltageM))
disp('Voltage Magnitudes from Non-convex AC-OPF')
solverM = nonconvex_results.bus(:,VM)
disp('Voltage Angles Vector from SDP')
display(value(voltageA))
disp('Voltage Angles from Non-convex AC-OPF')
solverA = nonconvex_results.bus(:,VA)

%% Vary network properties and evaluate exactness of relaxation

%     sdpopf5


%% 3 bus test case

%    sdpopf_6
 

%% Bonus

%    sdpopf_bonus
 