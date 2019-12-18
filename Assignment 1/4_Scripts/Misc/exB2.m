 %%
 clc 
clear all
close all

%%
 define_constants;
mpc= loadcase('swiss_dcopf_LP');
mpc.bus(:,3)=mpc.bus(:,3)*0.7;
 results = rundcopf(mpc);
 final_objective = results.f;