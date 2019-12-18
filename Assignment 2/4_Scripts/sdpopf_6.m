clear
close all
clc
define_constants
%% Load the appropriate matpower case file
mpc = case3_SDP;

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

%% Include penalty term in objective function

% Ask about including a penalty factor
prompt = 'Do you want to include a penalty factor on the reactive power injections? (0=no or 1=yes): ';
penalty = input(prompt);
if penalty==1
    prompt = 'Which weight value do you want to use? (e.g. 0.5): ';
    weight = input(prompt);
end

%% Change line limits
prompt = 'Change line limits? (0=no or 1=yes): ';
linelimits = input(prompt);
if linelimits==1
    mpc.branch(2,RATE_A)=50;
end

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
%         for k=G+1:N
%             Constraints = [Constraints, - mpc.bus(k,PD)/100 <= trace(Y_k(k)*W) <= - mpc.bus(k,PD)/100];
%             Constraints = [Constraints, - mpc.bus(k,QD)/100 <= trace(Y_k_(k)*W) <= - mpc.bus(k,QD)/100];
%         end
        
        %bus voltages
        for k=1:N
            Constraints = [Constraints, (mpc.bus(k,VMIN))^2 <= trace(M_k(k)*W) <= (mpc.bus(k,VMAX))^2];
        end
        
        %active branch flows
        for lm=1:L
            Constraints = [Constraints, -mpc.branch(lm,RATE_A)/100 <= trace(Y_lm(lm)*W) <= mpc.branch(lm,RATE_A)/100];
        end
        
        if penalty==1
            %objective semidefinite with penalty
            for k=1:G
            Constraints = [Constraints, [mpc.gencost(k,6)*1e2*trace(Y_k(k)*W) - alfa_k(k,1) + mpc.gencost(k,7) + mpc.gencost(k,6)*1e2*(mpc.bus(k,PD)/100)+weight*trace(Y_k_(k)*W),...
                                         sqrt(mpc.gencost(k,5)*1e4)*trace(Y_k(k)*W) + sqrt(mpc.gencost(k,5)*1e4)*(mpc.bus(k,PD)/100) ;...
                                         sqrt(mpc.gencost(k,5)*1e4)*trace(Y_k(k)*W) + sqrt(mpc.gencost(k,5)*1e4)*(mpc.bus(k,PD)/100), ...
                                         -1] <= 0];
            end    
        else
            %objective semidefinite without penalty
            for k=1:G
            Constraints = [Constraints, [mpc.gencost(k,6)*1e2*trace(Y_k(k)*W) - alfa_k(k,1) + mpc.gencost(k,7) + mpc.gencost(k,6)*1e2*(mpc.bus(k,PD)/100),...
                                         sqrt(mpc.gencost(k,5)*1e4)*trace(Y_k(k)*W) + sqrt(mpc.gencost(k,5)*1e4)*(mpc.bus(k,PD)/100) ;...
                                         sqrt(mpc.gencost(k,5)*1e4)*trace(Y_k(k)*W) + sqrt(mpc.gencost(k,5)*1e4)*(mpc.bus(k,PD)/100), ...
                                         -1] <= 0];
            end
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
    P_G(k,1)=trace(Y_k(k)*W)*100+mpc.bus(k,PD);
    Q_G(k,1)=trace(Y_k_(k)*W)*100+mpc.bus(k,QD);
end

display(value(P));
display(value(Q));
display(value(P_G));
display(value(Q_G));
display(value(sum(alfa_k,1)));

% Compare to non-convex AC-OPF results
nonconvex_results = runopf(mpc);
solverM = nonconvex_results.bus(:,VM);
solverA = nonconvex_results.bus(:,VA);

%% Post-process
% eig(A) might be helpful to calculate eigenvalues and -vectors of matrix A
lambda=value(eig(W));
lambda=sort(lambda,'descend');

if slack==1

    % Calculate eigenvalue ratio and evaluate exactness of the relaxation
    %scatter(1:18, lambda(:,1))
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
    %scatter(1:18, lambda(:,1))
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