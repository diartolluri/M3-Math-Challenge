% Quantifying the Financial Impact of Online Gambling
% Differential dynamics model based on the "Recovery Burden Months" metric

% Define baseline parameters for an individual over time
simulation_months = 60;   % 5 years

% The monthly harmful shortfall is q(t) = max(0, g(t) + s(t) - c(t))
g_monthly = 200;  % Gambling loss per month ($)
s_monthly = 50;   % Stress/leakage cost per month ($)
c_monthly = 100;  % Safe cushion ($)

% Allocation of shortfall across savings, investing, and debt (must sum to 1)
a = 0.5; % 50% from liquid savings
w = 0.3; % 30% from missed investing
b = 0.2; % 20% to new debt

% Interest/Return rates (annual)
r_annual  = 0.07; % 7% expected annual investment return
id_annual = 0.22; % 22% expected annual debt interest rate

% Milestone delay cost (e.g. extra rent, delayed emergency fund)
M = 1000; % ($)

% Normal monthly saving capacity 
C_rep = 500; % ($)

% Calculate the Recovery Burden Months
% This runs the counterfactual differential tracking the gaps over time.
RBM = calculate_RBM(simulation_months, g_monthly, s_monthly, c_monthly, a, w, b, r_annual, id_annual, M, C_rep);

% Output exactly what was asked in "One simple output"
fprintf('%.2f\n', RBM);
