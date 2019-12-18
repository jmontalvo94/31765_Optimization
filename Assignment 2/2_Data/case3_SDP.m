function mpc = case3_SDP
%CASE3    Power flow data for 3 bus, 3 generator case.
%   Please see CASEFORMAT for details on the case file format.
%
%   Based on data from
%     B. C. Lesieutre,  D. K. Molzahn,  A. R. Borden,  and C. L. De-
%     Marco, “Examining the limits of the application of semidefinite
%     programming to power flow problems,” in
%     Communication, Control, and Computing (Allerton), 2011 49th Annual Allerton Con-
%     ference on    IEEE, 2011, pp. 1492–1499


%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	110	40	0	0	1	1	0	345	1	1.1	0.9;
	2	2	110	40	0	0	1	1	0	345	1	1.1	0.9;
	3	2	95	50	0	0	1	1	0	345	1	1.1	0.9;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	0	0	300	-300	1	100	1	300	0	0	0	0	0	0	0	0	0	0	0	0;
	2	163	0	300	-300	1	100	1	300	0	0	0	0	0	0	0	0	0	0	0	0;
	3	85	0	300	-300	1	100	1	0	0	0	0	0	0	0	0	0	0	0	0	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	3	0.065	0.620	0.450	500	500	500	0	0	1	-360	360;
	3	2	0.025	0.750	0.700	60	500	500	0	0	1	-360	360;
	1	2	0.042	0.900   0.300	500	500	500	0	0	1	-360	360;
];

%%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	1500	0	3	0.11	5	150;
	2	2000	0	3	0.085	1.2	600;
	2	3000	0	3	0.1225	1	335;
];
