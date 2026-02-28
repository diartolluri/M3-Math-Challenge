% sensitivity_analysis_Q3.m
% Performs sensitivity analysis on the Recovery Burden Months (RBM) metric
% by varying key parameters and visualizing their impact using a Tornado diagram.

%% Baseline Parameters
base_months = 60;
base_g_monthly = 200;
base_s_monthly = 50;
base_c_monthly = 100;
base_a = 0.5;
base_w = 0.3;
base_b = 0.2;
base_r_annual = 0.07;
base_id_annual = 0.22;
base_M = 1000;
base_C_rep = 500;

% Calculate baseline RBM
baseline_RBM = calculate_RBM(base_months, base_g_monthly, base_s_monthly, ...
                             base_c_monthly, base_a, base_w, base_b, ...
                             base_r_annual, base_id_annual, base_M, base_C_rep);

%% Sensitivity Analysis Setup
% We will vary each continuous parameter by +/- 20%
variation = 0.20;

% Parameters to test
param_names = {'g_monthly', 's_monthly', 'c_monthly', ...
               'r_annual', 'id_annual', 'M', 'C_rep'};
           
param_labels = {'Gambling Loss (g\_monthly)', ...
                'Stress/Leakage (s\_monthly)', ...
                'Safe Cushion (c\_monthly)', ...
                'Investment Return (r\_annual)', ...
                'Debt Interest Rate (id\_annual)', ...
                'Milestone Delay Cost (M)', ...
                'Monthly Saving Capacity (C\_rep)'};

num_params = length(param_names);

% Store results
rbm_low = zeros(num_params, 1);
rbm_high = zeros(num_params, 1);
sensitivity_spread = zeros(num_params, 1);

for i = 1:num_params
    % Reset to baseline
    p = struct('g_monthly', base_g_monthly, 's_monthly', base_s_monthly, ...
               'c_monthly', base_c_monthly, 'r_annual', base_r_annual, ...
               'id_annual', base_id_annual, 'M', base_M, 'C_rep', base_C_rep);
           
    % Current parameter baseline value
    base_val = p.(param_names{i});
    
    % Low case (-20%)
    p.(param_names{i}) = base_val * (1 - variation);
    rbm_low(i) = calculate_RBM(base_months, p.g_monthly, p.s_monthly, ...
                               p.c_monthly, base_a, base_w, base_b, ...
                               p.r_annual, p.id_annual, p.M, p.C_rep);
                           
    % High case (+20%)
    p.(param_names{i}) = base_val * (1 + variation);
    rbm_high(i) = calculate_RBM(base_months, p.g_monthly, p.s_monthly, ...
                                p.c_monthly, base_a, base_w, base_b, ...
                                p.r_annual, p.id_annual, p.M, p.C_rep);
                            
    % Calculate spread (absolute difference from baseline)
    % We use the actual range for the tornado diagram sorting
    sensitivity_spread(i) = abs(rbm_high(i) - rbm_low(i));
end

%% Sort Parameters by Importance (Spread)
[sorted_spread, sort_idx] = sort(sensitivity_spread, 'ascend'); % Ascend for horizontal bar chart (widest at top)

sorted_labels = param_labels(sort_idx);
sorted_low = rbm_low(sort_idx);
sorted_high = rbm_high(sort_idx);

%% Display Ranking Textually
fprintf('Parameter Sensitivity Ranking (from MOST to LEAST important):\n');
fprintf('------------------------------------------------------------\n');
% Print in descending order
for i = num_params:-1:1
    idx = sort_idx(i);
    fprintf('%d. %-35s - Impact Spread: %6.2f months\n', ...
        num_params - i + 1, param_labels{idx}, sensitivity_spread(idx));
end

%% Plot Tornado Diagram
figure('Name', 'Sensitivity Analysis: Tornado Diagram', 'Position', [100, 100, 800, 500]);
hold on;

% Create the bars
for i = 1:num_params
    % Instead of traditional barh, using stacked bars where 
    % deviations from baseline are plotted right and left.
    change_high = sorted_high(i) - baseline_RBM;
    change_low = sorted_low(i) - baseline_RBM;
    
    % High value (+20%)
    if change_high >= 0
        h1 = barh(i, change_high, 'FaceColor', [0.8 0.2 0.2], 'EdgeColor', 'k', 'BaseValue', 0, 'BarWidth', 0.6);
    else
        h1 = barh(i, change_high, 'FaceColor', [0.2 0.6 0.2], 'EdgeColor', 'k', 'BaseValue', 0, 'BarWidth', 0.6);
    end
    
    % Low value (-20%)
    if change_low < 0
        h2 = barh(i, change_low, 'FaceColor', [0.2 0.6 0.2], 'EdgeColor', 'k', 'BaseValue', 0, 'BarWidth', 0.6);
    else
        h2 = barh(i, change_low, 'FaceColor', [0.8 0.2 0.2], 'EdgeColor', 'k', 'BaseValue', 0, 'BarWidth', 0.6);
    end
end

% Plot a vertical line at the baseline RBM change (which is 0)
plot([0 0], [0 num_params+1], 'k--', 'LineWidth', 1.5);

% Formatting
yticks(1:num_params);
yticklabels(sorted_labels);
xlabel('Change in Recovery Burden Months (RBM) from Baseline');
title(sprintf('Tornado Diagram of RBM Sensitivity (\\pm 20%% parameter variation)\nBaseline RBM = %.2f months', baseline_RBM));
grid on;

% Adjust limits
ylim([0.5 num_params+0.5]);
ax = gca;
ax.XAxis.Exponent = 0; % Prevent scientific notation

% Create legend entries
h_red = plot(NaN,NaN,'s','MarkerFaceColor',[0.8 0.2 0.2],'MarkerEdgeColor','k', 'MarkerSize', 10);
h_green = plot(NaN,NaN,'s','MarkerFaceColor',[0.2 0.6 0.2],'MarkerEdgeColor','k', 'MarkerSize', 10);
legend([h_red, h_green], {'Increases RBM (Worse)', 'Decreases RBM (Better)'}, 'Location', 'best');

hold off;
