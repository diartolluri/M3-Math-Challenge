%% Salary vs Disposable Income Graph for US (California) - All Family Combinations
% Parameters: Age=24, Country=US, State=California
% Salary range: 0 to $500,000

clear; clc;

%% Load essential costs data (US)
cost_data = readtable('essential_costs.csv', 'VariableNamingRule', 'preserve');

%% Define family compositions to analyze
family_compositions = struct(...
    'Adults', {1, 1, 2, 2}, ...
    'Children', {0, 1, 1, 2}, ...
    'Name', {'1 Adult, 0 Children', '1 Adult, 1 Child', '2 Adults, 1 Child', '2 Adults, 2 Children'});

num_compositions = length(family_compositions);

%% Generate salary range from 0 to 500,000
salary_range = 18:1:100;
num_points = length(salary_range);

%% Pre-allocate arrays
disposable_income = zeros(num_compositions, num_points);

%% Calculate for each family composition
for comp = 1:num_compositions
    fprintf('Calculating for %s...\n', family_compositions(comp).Name);
    
    % Define persona parameters - California
    params = struct(...
        'Country', 'US', ...
        'Region', 'California', ...
        'Adults', family_compositions(comp).Adults, ...
        'Children', family_compositions(comp).Children, ...
        'Age', 24);
    
    for i = 1:num_points
        % Create persona with current salary
        persona = params;
        persona.Salary = salary_range(i);
        
        % Module A: Calculate exact post-tax net income
        net_income = calculate_taxes(persona);
        
        % Module B: Estimate baseline single-adult essential costs
        base_essentials = calculate_essentials(persona, cost_data);
        
        % Module C: Convert baseline single-adult costs to individual's share
        indiv_essentials = apply_oecd_scale(base_essentials, persona.Adults, persona.Children);
        
        % Module D: Final Calculation Id = max(Net Income - Individual Essentials, 0)
        disposable_income(comp, i) = max(net_income - indiv_essentials, 0);
    end
end

fprintf('Calculation complete.\n');

%% Create single figure with all compositions on same graph
figure('Position', [100, 100, 900, 600]);

% Line colors for each composition
line_styles = {'b-', 'r-', 'g-', 'm-'};

% Plot disposable income for each family composition
for comp = 1:num_compositions
    plot(salary_range/1000, disposable_income(comp, :)/1000, line_styles{comp}, 'LineWidth', 2);
    hold on;
end

% Add reference line at y=0
yline(0, 'k-', 'LineWidth', 0.5);

% Formatting
xlabel('Gross Salary ($ thousands)', 'FontSize', 12);
ylabel('Disposable Income ($ thousands)', 'FontSize', 12);
title('Salary vs Disposable Income for US (California, Age=24)', 'FontSize', 14);
legend(family_compositions(1).Name, family_compositions(2).Name, family_compositions(3).Name, family_compositions(4).Name, 'Location', 'northwest');
grid on;

% Set axis limits
xlim([0, 500]);
ylim([0, max(disposable_income(:))/1000 + 10]);

%% Print summary statistics
fprintf('\n=== Summary Statistics (California) ===\n');
for comp = 1:num_compositions
    fprintf('\n%s:\n', family_compositions(comp).Name);
    fprintf('  Salary Range: $0 to $500,000\n');
    [max_di, max_idx] = max(disposable_income(comp, :));
    fprintf('  Maximum disposable income: $%.2f at salary $%.0f\n', max_di, salary_range(max_idx));
end
