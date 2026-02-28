% MAIN_Q2.m
% Agentic Markov Chain Simulation for Online Gambling Losses
clear; clc; close all;

% We define three different gamblers to simulate based on demographics
% Gambler(Age, Gender, Country, DisposableIncome, ChasingCoefficient)

% Simulation configuration
% Assume placing a bet every other day on average over one year (180 bets)

bet_count = 100; % number of bets per month
num_simulations = 100; % Number of simulations to average over

rng(42); % Set random seed for reproducibility

% Preallocate arrays for average profit history
g1_avg_profit_history = zeros(12, 1);
g2_avg_profit_history = zeros(12, 1);
g3_avg_profit_history = zeros(12, 1);

g1_avg_net_profit = 0;
g2_avg_net_profit = 0;
g3_avg_net_profit = 0;

% Run the year-long simulation multiple times for each agent
for i = 1:num_simulations
    % Group 1: Young Adult, high base risk tolerance, lower disposable income
    g1 = Gambler(22, "Male", "US", 35000, 1.001);
    
    % Group 2: Middle Aged, lower base risk tolerance, higher disposable income
    g2 = Gambler(45, "Female", "US", 65000, 1.005);
    
    % Group 3: Very Young Adult, high base risk tolerance, very low disposable income
    g3 = Gambler(19, "Male", "UK", 20000, 1.01);
    
    g1.simulate_year(bet_count);
    g2.simulate_year(bet_count);
    g3.simulate_year(bet_count);
    
    g1_avg_profit_history = g1_avg_profit_history + g1.ProfitHistory;
    g2_avg_profit_history = g2_avg_profit_history + g2.ProfitHistory;
    g3_avg_profit_history = g3_avg_profit_history + g3.ProfitHistory;
    
    g1_avg_net_profit = g1_avg_net_profit + g1.NetProfit;
    g2_avg_net_profit = g2_avg_net_profit + g2.NetProfit;
    g3_avg_net_profit = g3_avg_net_profit + g3.NetProfit;
end

% Calculate averages
g1_avg_profit_history = g1_avg_profit_history / num_simulations;
g2_avg_profit_history = g2_avg_profit_history / num_simulations;
g3_avg_profit_history = g3_avg_profit_history / num_simulations;

g1_avg_net_profit = g1_avg_net_profit / num_simulations;
g2_avg_net_profit = g2_avg_net_profit / num_simulations;
g3_avg_net_profit = g3_avg_net_profit / num_simulations;

% ---------------------------------------------------------
% Plot the average cumulative profit/loss history
% ---------------------------------------------------------
figure('Name', 'Yearly Sports Betting Simulation (Averaged)', 'Color', 'w');
hold on;
plot(1:12, g1_avg_profit_history, 'LineWidth', 2, 'DisplayName', 'Agent 1: 22yo Male ($35k Income)');
plot(1:12, g2_avg_profit_history, 'LineWidth', 2, 'DisplayName', 'Agent 2: 45yo Female ($65k Income)');
plot(1:12, g3_avg_profit_history, 'LineWidth', 2, 'DisplayName', 'Agent 3: 19yo Male ($20k Income)');
hold off;

title(sprintf('Average Cumulative Profit/Loss Over One Year (%d Simulations)', num_simulations));
xlabel('Months');
ylabel('Average Cumulative Profit (USD)');
legend('Location', 'best');
grid on;

% ---------------------------------------------------------
% Display end-of-year summaries
% ---------------------------------------------------------
fprintf('--- Average Simulation Results (%d Simulations) ---\n', num_simulations);
fprintf('Agent 1 (22yo): Average Net Profit = $%.2f, Base Risk = %.2f%%\n', g1_avg_net_profit, g1.BaseRiskTolerance * 100);
fprintf('Agent 2 (45yo): Average Net Profit = $%.2f, Base Risk = %.2f%%\n', g2_avg_net_profit, g2.BaseRiskTolerance * 100);
fprintf('Agent 3 (19yo): Average Net Profit = $%.2f, Base Risk = %.2f%%\n', g3_avg_net_profit, g3.BaseRiskTolerance * 100);
