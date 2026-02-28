% MAIN_Q1_monthly.m
% Primary script that calculates and plots the monthly disposable income
% over a 12-month period for various demonstration personas.

function main_Q1_monthly()
    % 1. Load the empirical essential costs data
    if ~exist('essential_costs.csv', 'file')
        error('MAIN_Q1_monthly:MissingFile', 'Could not find essential_costs.csv in the current directory.');
    end
    
    cost_data = readtable('essential_costs.csv', 'VariableNamingRule', 'preserve');

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
    results = cell(num_personas, 4);

    % 3. Setup figure for plotting
    figure('Name', 'Monthly Disposable Income', 'Position', [100, 100, 800, 500]);
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
        monthly_indiv_essentials = annual_indiv_essentials / 12;
        
        % Module D: Final Calculation Monthly Id
        monthly_Id = max(monthly_net_income - monthly_indiv_essentials, 0);
        
        % Array of disposable income over 12 months (Fixed over time)
        monthly_Id_array = repmat(monthly_Id, 1, 12);
        
        % Total disposable income over 12 months
        total_12_month_Id = sum(monthly_Id_array);
        
        % Plot the monthly series for this persona
        plot(months, monthly_Id_array, '-o', 'LineWidth', 2, 'Color', colors(i,:), ...
             'DisplayName', p.Description);
        
        % Store results
        results{i, 1} = string(p.Description);
        results{i, 2} = monthly_Id;
        results{i, 3} = total_12_month_Id;
    end

    % 5. Format the Plot
    title('Monthly Disposable Income over 12 Months');
    xlabel('Month');
    ylabel('Disposable Income ($ / £)');
    xlim([0.5, 12.5]);
    xticks(1:12);
    grid on;
    legend('Location', 'eastoutside');
    hold off;

    % 6. Create and print the formatted MATLAB table
    output_table = cell2table(results(:, 1:3), ...
        'VariableNames', {'Persona', 'Monthly_Disposable_Income', 'Total_12_Month_Disposable_Income'});
    
    disp('---------------------------------------------------------');
    disp('   Monthly Deterministic Rule-Based Accounting Model     ');
    disp('---------------------------------------------------------');
    disp(output_table);

end