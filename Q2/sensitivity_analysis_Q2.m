% sensitivity_analysis_Q2.m
% One-At-A-Time (OAT) Sensitivity Analysis for Gambler Simulation

clear; clc; close all;

num_simulations = 500; % High enough for stable averages without taking too long

% --- Baseline values ---
base_age = 25;
base_income = 40000;
base_chase = 1.1;
base_bet_count = 5;

% --- Parameter ranges [low, high] ---
% We define sensible low and high ranges for each parameter to see the effect 
% of changing each parameter from its baseline.
range_age = [18, 45];
range_income = [20000, 60000];
range_chase = [0.9, 1.3];
range_bet = [2, 10];

fprintf('Running sensitivity analysis (%d simulations per scenario)...\n', num_simulations);

% --- Calculate Baseline ---
fprintf('Calculating baseline...\n');
base_profit = run_sim_q2(base_age, base_income, base_chase, base_bet_count, num_simulations);
fprintf('Baseline Average Net Profit: $%.2f\n', base_profit);

% --- Evaluate extremes for Age ---
fprintf('Evaluating Age = [%d, %d]...\n', range_age(1), range_age(2));
prof_age_low = run_sim_q2(range_age(1), base_income, base_chase, base_bet_count, num_simulations);
prof_age_high = run_sim_q2(range_age(2), base_income, base_chase, base_bet_count, num_simulations);

% --- Evaluate extremes for Income ---
fprintf('Evaluating Saved Income = [$%d, $%d]...\n', range_income(1), range_income(2));
prof_inc_low = run_sim_q2(base_age, range_income(1), base_chase, base_bet_count, num_simulations);
prof_inc_high = run_sim_q2(base_age, range_income(2), base_chase, base_bet_count, num_simulations);

% --- Evaluate extremes for Chasing Coefficient ---
fprintf('Evaluating Chasing Coefficient = [%.2f, %.2f]...\n', range_chase(1), range_chase(2));
prof_chase_low = run_sim_q2(base_age, base_income, range_chase(1), base_bet_count, num_simulations);
prof_chase_high = run_sim_q2(base_age, base_income, range_chase(2), base_bet_count, num_simulations);

% --- Evaluate extremes for Bet Count ---
fprintf('Evaluating Bet Count = [%d, %d]...\n', range_bet(1), range_bet(2));
prof_bet_low = run_sim_q2(base_age, base_income, base_chase, range_bet(1), num_simulations);
prof_bet_high = run_sim_q2(base_age, base_income, base_chase, range_bet(2), num_simulations);

% --- Calculate swings and rank ---
% Collecting results
params = {'Age (18 - 45)', 'Saved Income ($20k - $60k)', 'Chasing Coeff (0.9 - 1.3)', 'Bet Count (2 - 10)'};
low_vals = [prof_age_low, prof_inc_low, prof_chase_low, prof_bet_low];
high_vals = [prof_age_high, prof_inc_high, prof_chase_high, prof_bet_high];

% A swing is the absolute difference between the parameter's minimum and maximum outcomes
swings = abs(high_vals - low_vals);

% Sort by swing magnitude to rank importance
[sorted_swings, sort_idx] = sort(swings, 'ascend'); % Ascend for barh plot (largest swing at top of chart)
sorted_params = params(sort_idx);
sorted_low = low_vals(sort_idx);
sorted_high = high_vals(sort_idx);

% Display descending ranking back to console
fprintf('\n--- Sensitivity Ranking (Most to Least Important) ---\n');
for i = length(sorted_swings):-1:1
    fprintf('%d. %s (Swing: $%.2f)\n', length(sorted_swings) - i + 1, sorted_params{i}, sorted_swings(i));
end

% --- Plot Tornado Chart ---
figure('Name', 'Sensitivity Analysis Tornado Chart', 'Color', 'w');
hold on;

% Draw tornado bars
for i = 1:length(sorted_swings)
    % We compute distance from baseline for both low and high results
    % Draw the lower bound block
    plot([sorted_low(i), base_profit], [i, i], 'LineWidth', 20, 'Color', [0.8500 0.3250 0.0980]); % Orange
    % Draw the higher bound block
    plot([base_profit, sorted_high(i)], [i, i], 'LineWidth', 20, 'Color', [0 0.4470 0.7410]); % Blue
end

% Draw baseline vertical line
plot([base_profit, base_profit], [0, length(sorted_swings)+1], 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');

% Format Chart
set(gca, 'YTick', 1:length(sorted_params), 'YTickLabel', sorted_params, 'FontSize', 10);
ylim([0.5, length(sorted_params) + 0.5]);
xlabel('Average Annual Net Profit (USD)', 'FontSize', 12, 'FontWeight', 'bold');
title('Sensitivity Analysis of Annual Gambling Profit', 'FontSize', 14);

% Add custom legends for colored bars
% Mock scatter plots to produce legend entries with correct colors
h1 = plot(NaN, NaN, 'LineWidth', 8, 'Color', [0.8500 0.3250 0.0980]);
h2 = plot(NaN, NaN, 'LineWidth', 8, 'Color', [0 0.4470 0.7410]);
legend([h1, h2], {'Result of Lower Parameter Bound', 'Result of Upper Parameter Bound'}, 'Location', 'best', 'Box', 'off');

grid on;
hold off;

% --- Helper Functions ---
function avg_profit = run_sim_q2(age, savedIncome, chasingCoeff, bet_count, num_sims)
    % To keep results purely deterministic for the analysis and comparisons:
    rng(42);
    
    total_profit = 0;
    
    for i = 1:num_sims
        % We fix remaining attributes: "US", "Male", 0 starting wealth, max_bet_per_month = false
        g = Gambler(age, "Male", "US", 0, savedIncome, chasingCoeff, false);
        g.simulate_year(bet_count);
        total_profit = total_profit + g.NetProfit;
    end
    
    avg_profit = total_profit / num_sims;
end
