clc 
clear all
close all

%%
 define_constants;
mpc= loadcase('swiss_dcopf_LP');

 results = rundcopf(mpc);
 final_objective = results.f;
 

 