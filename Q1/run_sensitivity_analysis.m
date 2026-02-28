% run_sensitivity_analysis.m
addpath('Q1');
% Load base data
cost_data_orig = readtable('Q1/data/essential_costs.csv', 'VariableNamingRule', 'preserve');

personas = struct(...
    'Description', { ...
        'Young Single, TX (US)', ...
        'Young Single, CA (US)', ...
        'Mid-Career Single, NY (US)', ...
        'Mid-Career Family, NY (US)', ...
        'Pre-Retiree, FL (US)', ...
        'Young Single, England (UK)', ...
        'Mid-Career Family, Scotland (UK)', ...
        'Pensioner, Wales (UK)' ...
    }, ...
    'Salary',   {35000, 35000, 120000, 120000, 65000,  35000,   65000,    25000}, ...
    'Age',      {   24,    24,     40,     40,    62,     28,      45,       72}, ...
    'Country',  { 'US',  'US',   'US',   'US',  'US',   'UK',    'UK',     'UK'}, ...
    'Region',   {'Texas', 'California', 'New York', 'New York', 'Florida', 'England', 'Scotland', 'Wales'}, ...
    'Adults',   {    1,     1,      1,      2,     2,      1,       2,        1}, ...
    'Children', {    0,     0,      0,      2,     0,      0,       2,        0} ...
);

factors = {'Salary', 'Base_Housing_Annual', 'Base_Food_Annual', 'Base_Transport_Annual', 'Base_Healthcare_Annual'};
factor_labels = {'Gross Salary', 'Housing Costs', 'Food Costs', 'Transport Costs', 'Healthcare Costs'};
num_factors = length(factors);
num_personas = length(personas);

% Arrays to store the boundaries of the swings for the Tornado Chart
% We will analyze Persona 1 (Texas, US) and Persona 6 (England, UK) for the figures
selected_personas = [1, 6]; 
di_minus_10 = zeros(length(selected_personas), num_factors);
di_plus_10 = zeros(length(selected_personas), num_factors);
baseline_di = zeros(length(selected_personas), 1);

% For overall ranking, we compute avg elasticity across ALL personas
elasticity = zeros(num_personas, num_factors);

for p_idx = 1:num_personas
    p = personas(p_idx);
    
    % Baseline calculation
    net_inc = calculate_taxes(p);
    base_ess = calculate_essentials(p, cost_data_orig);
    indiv_ess = apply_oecd_scale(base_ess, p.Adults, p.Children);
    monthly_di = max(net_inc/12 - indiv_ess/12, 0);
    total_baseline_di = sum(monthly_di);
    
    if ismember(p_idx, selected_personas)
        sel_idx = find(selected_personas == p_idx);
        baseline_di(sel_idx) = total_baseline_di;
    end
    
    for f_idx = 1:num_factors
        factor = factors{f_idx};
        
        % -10% change
        cost_data_mod = cost_data_orig;
        p_mod = p;
        if strcmp(factor, 'Salary')
            p_mod.Salary = p.Salary * 0.90;
        else
            cost_data_mod.(factor) = cost_data_mod.(factor) * 0.90;
        end
        net_inc = calculate_taxes(p_mod);
        base_ess = calculate_essentials(p_mod, cost_data_mod);
        indiv_ess = apply_oecd_scale(base_ess, p_mod.Adults, p_mod.Children);
        di_min = sum(max(net_inc/12 - indiv_ess/12, 0));
        
        % +10% change
        cost_data_mod = cost_data_orig;
        p_mod = p;
        if strcmp(factor, 'Salary')
            p_mod.Salary = p.Salary * 1.10;
        else
            cost_data_mod.(factor) = cost_data_mod.(factor) * 1.10;
        end
        net_inc = calculate_taxes(p_mod);
        base_ess = calculate_essentials(p_mod, cost_data_mod);
        indiv_ess = apply_oecd_scale(base_ess, p_mod.Adults, p_mod.Children);
        di_max = sum(max(net_inc/12 - indiv_ess/12, 0));
        
        % Save for tornado
        if ismember(p_idx, selected_personas)
            sel_idx = find(selected_personas == p_idx);
            di_minus_10(sel_idx, f_idx) = di_min;
            di_plus_10(sel_idx, f_idx) = di_max;
        end
        
        % Compute sensitivity/elasticity (absolute \% change in DI for a 10% change in factor)
        % Using the +10% case to calculate impact
        if total_baseline_di > 0
            pct_change_di = abs(di_max - total_baseline_di) / total_baseline_di;
        else
            pct_change_di = 0; % Avoid division by zero if baseline DI is 0
        end
        elasticity(p_idx, f_idx) = pct_change_di;
    end
end

% Rank the factors based on the average elasticity across all personas
avg_elasticity = mean(elasticity, 1) * 100; % as %
[sorted_elast, sort_idx] = sort(avg_elasticity, 'descend');
sorted_labels = factor_labels(sort_idx);

fprintf('\n==== SENSITIVITY RANKING (Most to Least Important) ====\n');
for i = 1:num_factors
    fprintf('%d. %s (Avg impact on Disposable Income: %.1f%%)\n', i, sorted_labels{i}, sorted_elast(i));
end

%% Plot Tornado Charts
figure('Name', 'Sensitivity Analysis Tornado Charts', 'Position', [100, 100, 1200, 500]);

for s = 1:length(selected_personas)
    subplot(1, 2, s);
    p_name = personas(selected_personas(s)).Description;
    base_val = baseline_di(s);
    
    % Sort by swing magnitude for this specific persona to make it a true Tornado
    swings = abs(di_plus_10(s, :) - di_minus_10(s, :));
    [~, p_sort] = sort(swings, 'ascend'); 
    
    % Data for this subplot
    y = 1:num_factors;
    val_min = di_minus_10(s, p_sort);
    val_max = di_plus_10(s, p_sort);
    labels_ord = factor_labels(p_sort);
    
    hold on;
    % For each factor, plot a bar from baseline to min and baseline to max
    for i = 1:num_factors
        % -10% parameter change bar
        b1 = barh(y(i), val_min(i) - base_val, 'FaceColor', [0.8500 0.3250 0.0980], 'EdgeColor', 'none', 'BaseValue', 0);
        % +10% parameter change bar
        b2 = barh(y(i), val_max(i) - base_val, 'FaceColor', [0 0.4470 0.7410], 'EdgeColor', 'none', 'BaseValue', 0);
    end
    
    % Formatting
    plot([0 0], [0 num_factors+1], 'k-', 'LineWidth', 1.5); % Baseline line
    yticks(y);
    yticklabels(labels_ord);
    xlabel('Change in Annual Disposable Income');
    if personas(selected_personas(s)).Country == "US"
        currency = '$';
    else
        currency = '£';
    end
    title(sprintf('Tornado Diagram: %s\nBaseline DI: %s%.0f', p_name, currency, base_val));
    grid on;
    
    if s == 1
        legend([b2, b1], {'+10% Change in Parameter', '-10% Change in Parameter'}, 'Location', 'best');
    end
end
