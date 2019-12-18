clc 
clear all
close all
mpc=swiss_dcopf_LP;
load=[]
wind=[]
step=0.02
lmpf=[];
k=1;
for lp = .20:step:1
    lpm=[]
    for wp=0:step:1
        mpci=mpc
        mpci.bus(:,3)=mpci.bus(:,3)*lp
        mpci.gen(5,9)=mpci.gen(5,9)*wp
        results=rundcopf(mpci)
        lpm=[lpm,results.bus(10,14)]; 
        %if (lp==.2) && (wp==1)
          %  lmpf=[lpm];
       % end
    end
    %if lp~=0.2 
        lmpf(k,:)=lpm;
        k=k+1;
    %end
    
end

        load=[.2:step:1];
        wind=[0:step:1];
 surf(wind,load,lmpf)
 xlabel('wind/%')
ylabel('load/%')
zlabel('lmpf')