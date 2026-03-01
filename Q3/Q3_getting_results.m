% Q3_Creative_Insights.m
% This script explores various scenarios using the calculate_RBM model
% to reveal hidden insights about the financial impact of gambling.
% It outputs 4 figures illustrating different non-obvious dynamics.

clear; clc; close all;

% Baseline parameters for use across some insights
months_base = 60;
s_monthly = 50;
c_monthly = 100;
a = 0.5; w = 0.3; b = 0.2;
r_annual = 0.07;
id_annual = 0.22;
M = 1000;
C_rep = 500;

%% Insight 1: The Long-Term Trap of Debt-Funded Gambling (The Compounding Effect)
% How does funding gambling through debt compare to missing out on investments or just using cash?
% We vary the time horizon up to 10 years (120 months) for three profiles.
time_horizons = 12:12:120; % 1 to 10 years in months
rbm_debt = zeros(size(time_horizons));
rbm_wealth = zeros(size(time_horizons));
rbm_cash = zeros(size(time_horizons));

% Assuming a flat $300 shortfall entirely funded by one source
for i = 1:length(time_horizons)
    % 100% Debt (b=1, a=0, w=0)
    rbm_debt(i)   = calculate_RBM(time_horizons(i), 300, 0, 0, 0, 0, 1.0, r_annual, id_annual, M, C_rep);
    % 100% Missed Investing (w=1, a=0, b=0)
    rbm_wealth(i) = calculate_RBM(time_horizons(i), 300, 0, 0, 0, 1.0, 0, r_annual, id_annual, M, C_rep);
    % 100% Cash Savings (a=1, w=0, b=0)
    rbm_cash(i)   = calculate_RBM(time_horizons(i), 300, 0, 0, 1.0, 0, 0, r_annual, id_annual, M, C_rep);
end

fig1 = figure('Name', 'Insight 1: Debt vs Wealth', 'Position', [100, 100, 700, 500]);
plot(time_horizons/12, rbm_debt, '-r', 'LineWidth', 2.5); hold on;
plot(time_horizons/12, rbm_wealth, '-b', 'LineWidth', 2.5);
plot(time_horizons/12, rbm_cash, '-g', 'LineWidth', 2.5);
title('Insight 1: The Exponential Trap of Debt-Funded Gambling', 'FontSize', 14);
xlabel('Duration of Gambling Habit (Years)', 'FontSize', 12);
ylabel('Recovery Burden (Months)', 'FontSize', 12);
legend('100% Debt-Funded (22% APR)', '100% Missed Investing (7% Return)', '100% Cash Savings (0% Return)', 'Location', 'northwest', 'FontSize', 11);
grid on;
% INSIGHT: Debt-funded gambling creates an exponential burden. A 10-year habit funded by
% credit cards requires more than double the recovery time compared to purely losing cash 
% due to toxic compounding interest.


%% Insight 2: The "Safe Cushion" Illusion (Heatmap)
% Many believe that budgeting a "safe cushion" protects them. 
% But what happens when gambling losses + stress leaks slightly exceed the cushion?
g_range = linspace(0, 400, 40);
c_range = linspace(0, 400, 40);
[G_grid, C_grid] = meshgrid(g_range, c_range);
RBM_grid = zeros(size(G_grid));

for i = 1:size(G_grid, 1)
    for j = 1:size(G_grid, 2)
        % We use the baseline allocation (a=0.5, w=0.3, b=0.2)
        RBM_grid(i,j) = calculate_RBM(months_base, G_grid(i,j), s_monthly, C_grid(i,j), a, w, b, r_annual, id_annual, M, C_rep);
    end
end

fig2 = figure('Name', 'Insight 2: Safe Cushion', 'Position', [150, 150, 700, 500]);
contourf(G_grid, C_grid, RBM_grid, 20, 'LineColor', 'none');
cbar = colorbar;
ylabel(cbar, 'Recovery Burden (Months)', 'FontSize', 11);
title('Insight 2: The "Safe Cushion" Illusion (5-Year Horizon)', 'FontSize', 14);
xlabel('Monthly Gambling Loss ($)', 'FontSize', 12);
ylabel('Budgeted Safe Cushion ($)', 'FontSize', 12);
hold on;
% Add a line where Loss + Stress = Cushion (Break-even line)
plot(g_range, g_range + s_monthly, 'r--', 'LineWidth', 2);
text(150, 150 + s_monthly + 20, 'Financial Break-Even Boundary', 'Color', 'r', 'Rotation', 40, 'FontWeight', 'bold', 'FontSize', 11);
% INSIGHT: The transition from 0 recovery burden to a massive burden is incredibly steep.
% Because of the $50 "stress leakage" (e.g. tilted decision making, convenience fees), 
% gamblers hit the danger zone sooner than they realize, turning a supposed "safe" habit into a crisis.


%% Insight 3: The Tipping Point of Debt Allocation
% For a fixed monthly shortfall, as debt allocation slowly replaces lost savings, 
% how does the recovery burden respond?
b_range = linspace(0, 1, 50);
rbm_b = zeros(size(b_range));
for i = 1:length(b_range)
    % As debt allocation increases from 0 to 1, savings allocation drops (w is kept at 0)
    current_b = b_range(i);
    current_a = 1 - current_b; 
    rbm_b(i) = calculate_RBM(months_base, 300, 0, 0, current_a, 0, current_b, r_annual, id_annual, M, C_rep);
end

fig3 = figure('Name', 'Insight 3: Debt Tipping Point', 'Position', [200, 200, 700, 500]);
plot(b_range * 100, rbm_b, 'LineWidth', 2.5, 'Color', '#D95319');
title('Insight 3: The Slippery Slope of Borrowing to Gamble', 'FontSize', 14);
xlabel('Percentage of Shortfall Funded by Debt (%)', 'FontSize', 12);
ylabel('Recovery Burden (Months)', 'FontSize', 12);
grid on;
% INSIGHT: Taking on debt to cover a shortfall doesn't just add to the burden linearly.
% As the debt ratio increases, the recovery burden accelerates (curves upwards) due to 
% compounding interest over the 5 years, highlighting the extreme danger of betting on credit.


%% Insight 4: The Milestone Cost Trap (Regressive Impact)
% How does a delayed milestone target (e.g., delaying a house downpayment requiring extra rent,
% or missing out on an emergency fund leading to a crisis loan) penalize those with lower savings capacity?
C_rep_range = linspace(200, 1500, 50);
rbm_M_high = zeros(size(C_rep_range));
rbm_M_low = zeros(size(C_rep_range));

for i = 1:length(C_rep_range)
    % Large milestone penalty of $5000 (e.g., a massive unexpected life cost due to empty savings)
    rbm_M_high(i) = calculate_RBM(months_base, 200, 50, 100, a, w, b, r_annual, id_annual, 5000, C_rep_range(i));
    % No milestone penalty
    rbm_M_low(i) = calculate_RBM(months_base, 200, 50, 100, a, w, b, r_annual, id_annual, 0, C_rep_range(i));
end

fig4 = figure('Name', 'Insight 4: Regressive Impact', 'Position', [250, 250, 700, 500]);
plot(C_rep_range, rbm_M_high, 'LineWidth', 2.5, 'Color', '#7E2F8E'); hold on;
plot(C_rep_range, rbm_M_low, 'LineWidth', 2.5, 'Color', '#0072BD');
title('Insight 4: Regressive Impact on Lower-Income Gamblers', 'FontSize', 14);
xlabel('Monthly Replenishment / Savings Capacity ($)', 'FontSize', 12);
ylabel('Recovery Burden (Months)', 'FontSize', 12);
legend('With $5000 Life Milestone Penalty', 'Without Penalty', 'Location', 'northeast', 'FontSize', 11);
grid on;
% INSIGHT: Gamblers with lower income/savings capacity suffer disproportionately.
% A flat penalty for missing a financial milestone makes the recovery time cleanly decouple 
% and skyrocket for lower-income individuals. A $5000 penalty means 25+ extra months of toil 
% for someone saving $200/mo, but is a mere blip for someone saving $1500/mo.

disp('Creative insights generated successfully! 4 figures have been created.');
