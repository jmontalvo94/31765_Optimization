clc 
clear all
close all
mpci=swiss_dcopf_LP;
define_constants;
mpc=mpci
load=[]
wind=[]
step=0.01
lmpf=[];
k=1;
%% Define your optimization variables
% Create the relevant vectors and assign them the appropriate size
delta= sdpvar(10,1);

c=[0,6.9,24.3,0,29.1,0,0,50,0,3];

b=[];
b(:,1)=mpc.branch(:,1);
b(:,2)=mpc.branch(:,2);
b(:,3)=1./mpc.branch(:,4);

P=sdpvar(10,1);
for i= [ 1,4,6,7,9]
    P(i)=0;
end
%% Calculate the Bus Reactance Matrix B
B=zeros(10);
sum=0;
for i=1:10
    for j=1:10
        if i==j 
            for fr=1:14
                if b(fr,1)==i || b(fr,2)==i 
                    sum=sum+b(fr,3);
                end
            end
                B(i,j)=sum;
                sum=0;
        else 
            for fr=1:14
            B(b(fr,1),b(fr,2))=-b(fr,3);
            B(b(fr,2),b(fr,1))=-b(fr,3);
            end
        end
    end
end

%% Determine the objective function
Objective = c*P;



%% Change the load and generator
for lp = .20:step:1
    lpm=[]
    for wp=0:step:1
        mpc=mpci
        mpc.bus(:,3)=mpc.bus(:,3)*lp
        mpc.gen(5,9)=mpc.gen(5,9)*wp
            %equality constraints

        Constraints = [P(:,1)-mpc.bus(:,PD)==B*delta];
        
        %upper and lower bounds on optimization variables
        j=1;
        for i=[2 3 5 8 10]
    
            Constraints = [Constraints, mpc.gen(j,PMAX) >= P(i) >= mpc.gen(j,PMIN)];
            j=j+1;
        end

        for i = 1:14
            Constraints = [Constraints, mpc.branch(i,RATE_A) >= (1/mpc.branch(i,BR_X))*(delta(mpc.branch(i,F_BUS))-delta(mpc.branch(i,T_BUS))) >= -mpc.branch(i,RATE_A)];
        end
        optimize(Constraints, Objective)
        Le=-1*dual(Constraints(1));
        lpm=[lpm,Le(10)]; 
    end
        lmpf(k,:)=lpm;
        k=k+1;
    
end

 load=[.2:step:1];
 wind=[0:step:1];
 surf(wind,load,lmpf)
 colormap(jet) 
 xlabel('wind/%')
 ylabel('load/%')
 zlabel('lmpf')