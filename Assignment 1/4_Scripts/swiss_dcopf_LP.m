function mpc = swiss_dcopf_LP


% -------------------------------------------------------------------------------------------------------
% Data for the CH-FR-IT System (Matpower)
% -------------------------------------------------------------------------------------------------------


%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 1000;

%% bus data
%bus_i type	Pd	   Qd  Gs  Bs area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	1	55      0	0	0	1	1	0	400	1	1.1	0.9;
	2	3	55      0	0	0	1	1	0	400	1	1.1	0.9;
	3	2	1300	0	0	0	1	1	0	400	1	1.1	0.9;
	4	1	650     0	0	0	1	1	0	400	1	1.1	0.9;
	5	2	650     0	0	0	1	1	0	400	1	1.1	0.9;
	6	1	200     0	0	0	1	1	0	400	1	1.1	0.9;
	7	1	2600	0	0	0	1	1	0	400	1	1.1	0.9;
	8	2	3600	0	0	0	1	1	0	400	1	1.1	0.9;
	9	1	1100	0	0	0	1	1	0	400	1	1.1	0.9;
	10	1	1900	0	0	0	1	1	0	400	1	1.1	0.9;
    ];


%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	2	1200	0	300	-300	1	1000	1	1200	0	0	0	0	0	0	0	0	0	0	0	0;
	3	8000	0	300	-300	1	1000	1	8000	0	0	0	0	0	0	0	0	0	0	0	0;
	5	3000	0	300	-300	1	1000	1	3000	0	0	0	0	0	0	0	0	0	0	0	0;
    8	2000	0	300	-300	1	1000	1	2000	0	0	0	0	0	0	0	0	0	0	0	0;
   10	800     0	300	-300	1	1000	1	1000     0	0	0	0	0	0	0	0	0	0	0	0;
];


% % Specification of the Machine Data (except cost data)
% Machine.Number          = [1:5]' ;
% Machine.BusRef          = [2 3 5 10 8]' ; % changed: 7 -> 10 (Windparknode @ GenPort 4)
% Machine.Slack           = [2];
% Machine.ProdStart       = [ 0      0    0   0    0]/Misc.BaseMVA;
% Machine.ProdMax         = [1200 8000 3000 Inf 2000]/Misc.BaseMVA; % vierter Eintrag ist WP: 800 -> INF!!!!
% Machine.ProdMin         = [   0    0    0   0    0]/Misc.BaseMVA;


%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	3	0	0.10	0	3000   3000	3000	0	0	1	-360	360;
 	1	10	0	0.27	0	2000   2000 2000	0	0	1	-360	360;
	2	3	0	0.12	0	3500   3500 3500 	0	0	1	-360	360;
	2	9	0	0.07	0	2260   2260 2260 	0	0	1	-360	360;
	2	10	0	0.14	0	1580   1580 1580 	0	0	1	-360	360;
	3	4	0	0.10	0	1780   1780 1780 	0	0	1	-360	360;
	3	5	0	0.17	0	2150   2150 2150 	0	0	1	-360	360;
	3	6	0	0.17	0	3500   3500 3500 	0	0	1	-360	360;
	4	5	0	0.17	0	2150   2150 2150	0	0	1	-360	360;
    5	6	0	0.17	0	2800   2800 2800	0	0	1	-360	360;
	6	7	0	0.16	0	3500   3500 3500 	0	0	1	-360	360;
	7	8	0	0.25	0	2000   2000 2000 	0	0	1	-360	360;
    8	9	0	0.25	0	2260   2260 2260  	0	0	1	-360	360;
    8	10	0	0.07	0	3500   3500 3500  	0	0	1	-360	360;
];




%%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	0	0	2	6.9     0;
	2	0	0	2	24.3	0;
	2	0	0	2	29.1	0;
    2	0	0	2	50  	0;
    2	0	0	2	3   	0;
];

