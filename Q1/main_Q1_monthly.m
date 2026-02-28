% MAIN_Q1_monthly.m
% Primary script that calculates and plots the monthly disposable income
% over a 12-month period for various demonstration personas.

function main_Q1_monthly()
    % 1. Load the empirical essential costs data
    if ~exist('Q1/data/essential_costs.csv', 'file')
        error('MAIN_Q1_monthly:MissingFile', 'Could not find essential_costs.csv in the current directory.');
    end
    
    cost_data = readtable('Q1/data/essential_costs.csv', 'VariableNamingRule', 'preserve');

    % 2. Define the Demonstration Personas
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

    % Pre-allocate cell array for the final table data
    num_personas = length(personas);
    results = cell(num_personas, 7); % Ensure enough columns for new outputs
    
    % Additional setup for shock probability graphs
    % We will save metrics for plotting at the end
    prob_debts = zeros(num_personas, 1);
    median_dis = zeros(num_personas, 1);
    worst_5ths = zeros(num_personas, 1);
    labels = cell(num_personas, 1);

    % 3. Setup figure for plotting
    figure('Name', 'Monthly Disposable Income With Shocks', 'Position', [100, 100, 1000, 600]);
    hold on;
    colors = lines(num_personas);
    months = 1:12;

    % 4. Loop through each persona to calculate Monthly Disposable Income
    for i = 1:num_personas
        p = personas(i);
        
        % Module A: Calculate exact post-tax net income (Annual)
        annual_net_income = calculate_taxes(p);
        
        % Module B: Estimate baseline single-adult essential costs (Annual)
        annual_base_essentials = calculate_essentials(p, cost_data);
        
        % Module C: Convert baseline single-adult costs to individual's share of household costs (Annual)
        annual_indiv_essentials = apply_oecd_scale(annual_base_essentials, p.Adults, p.Children);
        
        % Convert Annual to Monthly
        monthly_net_income = annual_net_income / 12;
        monthly_indiv_essentials = annual_indiv_essentials / 12; % Now a 1x12 array
        
        % Module D: Final Calculation Monthly Id
        % Disposable income over 12 months (Varies due to utility costs)
        monthly_Id_array = max(monthly_net_income - monthly_indiv_essentials, 0);
        
        % Total disposable income over 12 months (without shocks)
        total_12_month_Id = sum(monthly_Id_array);
        
        avg_monthly_id = mean(monthly_Id_array);
        
        % Module E: Apply Monte Carlo simulated shocks to average monthly disposable income
        shock_results = simulate_monthly_shocks(avg_monthly_id, p.Age, p.Country, p.Adults, p.Children, 10000);

        % Plot the monthly series for this persona
        % (Optional: We plot the baseline over 12 months)
        plot(months, monthly_Id_array, '-o', 'LineWidth', 2, 'Color', colors(i,:), ...
             'DisplayName', p.Description);
        
        % Store structured results including shock simulation metrics
        results{i, 1} = string(p.Description);
        results{i, 2} = avg_monthly_id;
        results{i, 3} = total_12_month_Id;
        results{i, 4} = shock_results.Median_Monthly_Income;
        results{i, 5} = shock_results.Worst_5th_Percentile_Month;
        results{i, 6} = shock_results.Prob_of_Debt_Percent;
        
        % Collect array metrics for plotting after loop
        labels{i} = p.Description;
        prob_debts(i) = shock_results.Prob_of_Debt_Percent;
        median_dis(i) = shock_results.Median_Monthly_Income;
        worst_5ths(i) = shock_results.Worst_5th_Percentile_Month;
    end

    % 5. Format the Baseline Plot
    title('Baseline Monthly Disposable Income over 12 Months (Before Shocks)');
    xlabel('Month');
    ylabel('Disposable Income ($ / £)');
    xlim([0.5, 12.5]);
    xticks(1:12);
    grid on;
    legend('Location', 'eastoutside');
    hold off;
    
    % 6. Create Bar Charts for Shock Data
    % Figure 2: Probability of Debt
    figure('Name', 'Monte Carlo Shock Risk', 'Position', [150, 150, 1000, 800]);
    
    % Subplot 1: Probability of Debt (%)
    subplot(2, 1, 1);
    bar(prob_debts, 'FaceColor', [0.8500 0.3250 0.0980]);
    title('Probability of Going into Debt (Negative DI) in a Given Month');
    ylabel('Probability (%)');
    xticks(1:num_personas);
    xticklabels(labels);
    xtickangle(25);
    grid on;
    % Add text labels on bars
    for i = 1:num_personas
        text(i, prob_debts(i), sprintf('%.1f%%', prob_debts(i)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end

    % Subplot 2: Median vs 5th Percentile DI
    subplot(2, 1, 2);
    b = bar([median_dis, worst_5ths], 'grouped');
    title('Median vs. 5th Percentile Monthly Disposable Income Under Shocks');
    ylabel('Disposable Income ($ / £)');
    xticks(1:num_personas);
    xticklabels(labels);
    xtickangle(25);
    legend('Median DI', '5th Percentile DI (1-in-20 Bad Month)', 'Location', 'best');
    grid on;
    
    % 7. Create and print the formatted MATLAB table
    % Prune the dynamically expanded cell array to the required columns
    output_table = cell2table(results(:, 1:6), ...
        'VariableNames', {'Persona', 'Avg_Monthly_DI', 'Total_12Mo_DI', ...
                          'Median_DI_after_Shocks', 'Worst_5th_Pctile_DI', 'Prob_of_Debt_Pct'});
    
    disp('-------------------------------------------------------------------------------------------------------------------------');
    disp('                   Monthly Deterministic Rule-Based Accounting Model with Stochastic Shock Analysis                      ');
    disp('-------------------------------------------------------------------------------------------------------------------------');
    disp(output_table);

end