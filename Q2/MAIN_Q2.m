% MAIN_Q2.m
% Agentic Markov Chain Simulation for Online Gambling Losses
clear; clc; close all;

% We define three different gamblers to simulate based on demographics
% Gambler(Age, Gender, Country, DisposableIncome, ChasingCoefficient)

% Group 1: Young Adult, high base risk tolerance, lower disposable income
g1 = Gambler(22, "Male", "US", 35000, 1.25);

% Group 2: Middle Aged, lower base risk tolerance, higher disposable income
g2 = Gambler(45, "Female", "US", 65000, 1.10);

% Group 3: Very Young Adult, high base risk tolerance, very low disposable income
g3 = Gambler(19, "Male", "UK", 20000, 1.30);

% Simulation configuration
% Assume placing a bet every other day on average over one year (180 bets)
total_bets = 180;
base_bet = 50;

rng(42); % Set random seed for reproducibility

% Run the year-long simulation for each agent
g1.simulate_year(total_bets, base_bet);
g2.simulate_year(total_bets, base_bet);
g3.simulate_year(total_bets, base_bet);

% ---------------------------------------------------------
% Plot the cumulative profit/loss history
% ---------------------------------------------------------
figure('Name', 'Yearly Sports Betting Simulation', 'Color', 'w');
hold on;
plot(1:total_bets, g1.ProfitHistory, 'LineWidth', 2, 'DisplayName', 'Agent 1: 22yo Male ($35k Income)');
plot(1:total_bets, g2.ProfitHistory, 'LineWidth', 2, 'DisplayName', 'Agent 2: 45yo Female ($65k Income)');
plot(1:total_bets, g3.ProfitHistory, 'LineWidth', 2, 'DisplayName', 'Agent 3: 19yo Male ($20k Income)');
hold off;

title('Cumulative Profit/Loss Over One Year of Sports Betting');
xlabel('Number of Bets Placed');
ylabel('Cumulative Profit (USD)');
legend('Location', 'best');
grid on;

% ---------------------------------------------------------
% Display end-of-year summaries
% ---------------------------------------------------------
fprintf('--- Simulation Results (End of Year) ---\n');
fprintf('Agent 1 (22yo): Net Profit = $%.2f, Base Risk = %.2f%%\n', g1.NetProfit, g1.BaseRiskTolerance * 100);
fprintf('Agent 2 (45yo): Net Profit = $%.2f, Base Risk = %.2f%%\n', g2.NetProfit, g2.BaseRiskTolerance * 100);
fprintf('Agent 3 (19yo): Net Profit = $%.2f, Base Risk = %.2f%%\n', g3.NetProfit, g3.BaseRiskTolerance * 100);
