% MAIN_Q1.m
% Primary script that loads the data, defines the demonstration personas, 
% loops through them, and prints the final output table.

function main_Q1()
    % 1. Load the empirical essential costs data
    if ~exist('essential_costs.csv', 'file')
        error('MAIN_Q1:MissingFile', 'Could not find essential_costs.csv in the current directory.');
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
    results = cell(num_personas, 7);

    % 3. Loop through each persona to calculate Disposible Income
    for i = 1:num_personas
        p = personas(i);
        
        % Module A: Calculate exact post-tax net income
        net_income = calculate_taxes(p);
        
        % Module B: Estimate total household essential costs
        household_essentials = calculate_essentials(p, cost_data);
        
        % Module C: Convert household costs to individual costs using OECD scale
        indiv_essentials = apply_oecd_scale(household_essentials, p.Adults, p.Children);
        
        % Module D: Final Calculation Id = max(Net Income - Individual Essentials, 0)
        Id = max(net_income - indiv_essentials, 0);
        
        % Store results
        results{i, 1} = string(p.Description);
        results{i, 2} = string(p.Country);
        results{i, 3} = string(p.Region);
        results{i, 4} = p.Salary;
        results{i, 5} = net_income;
        results{i, 6} = indiv_essentials;
        results{i, 7} = Id;
    end

    % 4. Create and print the formatted MATLAB table
    output_table = cell2table(results, ...
        'VariableNames', {'Persona', 'Country', 'Region', 'Gross_Salary', 'Net_Income', 'Individual_Essentials', 'Disposable_Income'});
    
    disp('---------------------------------------------------------');
    disp('   Deterministic Rule-Based Accounting Model Output      ');
    disp('---------------------------------------------------------');
    disp(output_table);

end