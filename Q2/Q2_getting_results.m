% Q2_Creative_Insights.m
% Uncovering hidden insights using the Agentic Markov Chain Model
clear; clc; close all;

fprintf('Running Creative Insights Scenarios for Q2...\n');

% Set random seed for reproducibility
rng(123);

num_sims = 200; % Number of simulations per scenario
betting_freq = 5;

%% Insight 1: The "Aging Out" of Parlays (Age vs. Risk Profile and Profit)
fprintf('Simulating Insight 1: Age vs Risk Profile...\n');
ages = 18:2:85;
avg_profit_by_age_m = zeros(size(ages));
avg_profit_by_age_f = zeros(size(ages));
risk_level_m = zeros(size(ages));

for i = 1:length(ages)
    profit_m = 0;
    profit_f = 0;
    for s = 1:num_sims
        gm = Gambler(ages(i), "Male", 10000, 40000, 1.2, true);
        gf = Gambler(ages(i), "Female", 10000, 40000, 1.2, true);
        
        gm.simulate_year(betting_freq);
        gf.simulate_year(betting_freq);
        
        profit_m = profit_m + gm.NetProfit;
        profit_f = profit_f + gf.NetProfit;
        
        if s == 1
            risk_level_m(i) = gm.BaseRiskTolerance * 2.0; % Effective risk
        end
    end
    avg_profit_by_age_m(i) = profit_m / num_sims;
    avg_profit_by_age_f(i) = profit_f / num_sims;
end

figure('Name', 'Insight 1: Aging Out of Risky Bets', 'Color', 'w', 'Position', [100, 100, 800, 600]);
subplot(2,1,1)
plot(ages, avg_profit_by_age_m, 'b-o', 'LineWidth', 2); hold on;
plot(ages, avg_profit_by_age_f, 'r-o', 'LineWidth', 2);
title('Insight 1: Average Yearly Profit/Loss by Age');
xlabel('Age'); ylabel('Net Profit ($)');
legend('Male', 'Female', 'Location', 'best');
grid on;

subplot(2,1,2)
plot(ages, risk_level_m, 'k-x', 'LineWidth', 2); hold on;
yline(0.15, 'r--', 'High Risk Threshold (Parlays)', 'LineWidth', 1.5);
yline(0.08, 'g--', 'Avg Risk Threshold', 'LineWidth', 1.5);
title('Effective Initial Risk Level vs Age (Male)');
xlabel('Age'); ylabel('Effective Risk Level');
grid on;

%% Insight 2: The Cost of "Tilted" Betting (Chasing Losses)
fprintf('Simulating Insight 2: Chasing Losses...\n');
chasing_coeffs = [1.0, 1.1, 1.3, 1.5, 2.0];
avg_profit_chasing = zeros(length(chasing_coeffs), 12);

figure('Name', 'Insight 2: Defaulting to Chasing', 'Color', 'w', 'Position', [150, 150, 800, 400]);
hold on;
colors = lines(length(chasing_coeffs));

for i = 1:length(chasing_coeffs)
    history_sum = zeros(12, 1);
    for s = 1:num_sims
        % 25-year old male, typical demographic
        g = Gambler(25, "Male", 5000, 30000, chasing_coeffs(i), false);
        g.simulate_year(betting_freq);
        history_sum = history_sum + g.ProfitHistory;
    end
    avg_profit_chasing(i, :) = (history_sum / num_sims)';
    plot(1:12, avg_profit_chasing(i, :), 'Color', colors(i,:), 'LineWidth', 2, ...
        'DisplayName', sprintf('Chasing Coeff: %.1f', chasing_coeffs(i)));
end
title('Insight 2: Cumulative Loss based on "Tilted" Behavior (Chasing Losses)');
xlabel('Month'); ylabel('Cumulative Net Profit ($)');
legend('Location', 'southwest');
grid on;

%% Insight 3: Session Budgeting vs. Monthly "Mental Accounting"
fprintf('Simulating Insight 3: Budgeting Strategy...\n');
num_sims_large = 500;
prof_month_limit = zeros(num_sims_large, 1);
prof_session_limit = zeros(num_sims_large, 1);

for s = 1:num_sims_large
    % Monthly budgeter (max_bet_per_month = true)
    g_month = Gambler(35, "Male", 10000, 50000, 1.1, true);
    g_month.simulate_year(betting_freq);
    prof_month_limit(s) = g_month.NetProfit;
    
    % Session budgeter (max_bet_per_month = false)
    g_sess = Gambler(35, "Male", 10000, 50000, 1.1, false);
    g_sess.simulate_year(betting_freq);
    prof_session_limit(s) = g_sess.NetProfit;
end

figure('Name', 'Insight 3: Budgeting Strategy', 'Color', 'w', 'Position', [200, 200, 800, 400]);
histogram(prof_month_limit, 'BinWidth', 200, 'FaceAlpha', 0.6, 'DisplayName', 'Monthly Loss Limit (Mental Accounting)');
hold on;
histogram(prof_session_limit, 'BinWidth', 200, 'FaceAlpha', 0.6, 'DisplayName', 'Strict Session Loss Limit');
title('Insight 3: Distribution of Yearly Returns by Loss Limitation Strategy');
xlabel('Yearly Net Profit ($)');
ylabel('Frequency');
legend('Location', 'northwest');
grid on;

%% Insight 4: The Flat Tax of Online Gambling
fprintf('Simulating Insight 4: Income Scale...\n');
incomes = [20000, 40000, 60000, 100000, 150000];
relative_loss_pct = zeros(size(incomes));
absolute_loss = zeros(size(incomes));

for i = 1:length(incomes)
    inc = incomes(i);
    loss_sum = 0;
    for s = 1:num_sims
        g = Gambler(30, "Female", inc*0.2, inc, 1.2, true);
        g.simulate_year(betting_freq);
        loss_sum = loss_sum + g.NetProfit;
    end
    absolute_loss(i) = loss_sum / num_sims;
    relative_loss_pct(i) = (absolute_loss(i) / inc) * 100;
end

figure('Name', 'Insight 4: The Flat Tax of Gambling', 'Color', 'w', 'Position', [250, 250, 800, 400]);
yyaxis left
plot(incomes, absolute_loss, 'b-s', 'LineWidth', 2);
ylabel('Absolute Year-End Net Loss ($)');
xlabel('Disposable Income ($)');
ax = gca;
ax.YAxis(1).Color = 'b';

yyaxis right
plot(incomes, relative_loss_pct, 'r-d', 'LineWidth', 2);
ylabel('Net Loss as % of Disposable Income');
ax.YAxis(2).Color = 'r';
ylim([min(relative_loss_pct)-2, max(relative_loss_pct)+2]); % Add some visual padding

title('Insight 4: Impact Across Income Levels (The "Flat Tax" Effect)');
grid on;

fprintf('All insights generated successfully!\n');
