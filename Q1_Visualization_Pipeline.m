% Q1_Visualization_Pipeline.m
% Generates 4 publication-quality visualizations for 6 specific personas
% based on the methodology in main_Q1_monthly.m

function Q1_Visualization_Pipeline()
    % 1. Load the empirical essential costs data
    if ~exist('Q1/data/essential_costs.csv', 'file')
        error('Q1_Visualization_Pipeline:MissingFile', 'Could not find essential_costs.csv in Q1/data/.');
    end
    
    % Add Q1 path to access helper functions
    addpath('Q1');
    
    cost_data = readtable('Q1/data/essential_costs.csv', 'VariableNamingRule', 'preserve');

    % 2. Define the 6 Specific Test Personas
    personas = struct(...
        'Description', { ...
            'Baseline US Fam', ...
            'Baseline UK Fam', ...
            'Older Single US', ...
            'Large UK Fam', ...
            'High Income US', ...
            'Low Income US' ...
        }, ...
        'Salary',   {110000, 65000, 75000, 80000, 250000, 40000}, ...
        'Age',      {    35,    35,    62,    38,     30,    50}, ...
        'Country',  {  'US',  'UK',  'US',  'UK',   'US',  'US'}, ...
        'Region',   { 'Texas', 'England', 'Florida', 'Scotland', 'New York', 'California'}, ...
        'Adults',   {     2,     2,     1,     2,      1,     2}, ...
        'Children', {     2,     2,     0,     4,      0,     3} ...
    );

    num_personas = length(personas);
    
    % Storage for results
    metrics = struct('Label', cell(num_personas,1), ...
                     'Gross_Monthly', zeros(num_personas,1), ...
                     'Tax_Monthly', zeros(num_personas,1), ...
                     'Essential_Monthly', zeros(num_personas,1), ...
                     'Base_Disp_Monthly', zeros(num_personas,1), ...
                     'Worst_5th_Month', zeros(num_personas,1), ...
                     'Prob_Debt', zeros(num_personas,1));
    
    % Raw data for Persona 6
    p6_sim_data = [];

    % 3. Run Model for Each Persona
    for i = 1:num_personas
        p = personas(i);
        
        % A. Calculate Taxes (Annual -> Monthly)
        annual_net_income = calculate_taxes(p);
        monthly_net_income = annual_net_income / 12;
        
        annual_gross = p.Salary;
        monthly_gross = annual_gross / 12;
        monthly_tax = monthly_gross - monthly_net_income;
        
        % B. Calculate Essentials (Annual -> Monthly)
        % calculate_essentials returns single adult base annual cost
        annual_base_essentials_scalar = calculate_essentials(p, cost_data); 
        
        % apply_oecd_scale returns individual share of household costs
        annual_indiv_share_essentials = apply_oecd_scale(annual_base_essentials_scalar, p.Adults, p.Children);
        monthly_essentials = annual_indiv_share_essentials / 12;

        % C. Base Monthly Disposable
        % Note: calculate_essentials returns 1x12 array (monthly variation).
        % We need average monthly disposable for the simulation, per main_Q1_monthly.m logic.
        monthly_disposable_array = max(monthly_net_income - monthly_essentials, 0);
        monthly_disposable_scalar = mean(monthly_disposable_array);

        % D. Run Monte Carlo Simulation
        % Run the standard function to get aggregate stats using the MEAN monthly disposable
        stats = simulate_monthly_shocks(monthly_disposable_scalar, p.Age, p.Country, p.Adults, p.Children, 100000);
        
        % Store Metrics
        metrics(i).Label = p.Description;
        metrics(i).Gross_Monthly = monthly_gross;
        metrics(i).Tax_Monthly = monthly_tax;
        metrics(i).Essential_Monthly = mean(monthly_essentials); % Store average for the plot
        metrics(i).Base_Disp_Monthly = monthly_disposable_scalar;
        metrics(i).Worst_5th_Month = stats.Worst_5th_Percentile_Month;
        metrics(i).Prob_Debt = stats.Prob_of_Debt_Percent;
        
        % Special handling for Persona 6 (Low Income US) for Exhibit 2
        % Replicate the shock simulation logic to get the raw data vector
        if i == 6
             p6_sim_data = replicate_shock_simulation_outcome(monthly_disposable_scalar, p.Age, p.Country, p.Adults, p.Children, 100000);
        end
    end
    
    % 4. Generate Figure with 4 Subplots
    fig = figure('Name', 'Q1 Analysis Results', 'Color', 'w', 'Position', [50, 50, 1400, 1000]);
    t = tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
    
    % --- Exhibit 1: Proportional Income Burden ---
    nexttile;
    % Data Calculation: [Tax, Essentials, Disposable]
    % We stack these three components.
    % Note: Base_Disp is net - essentials. 
    % Gross = Tax + Net = Tax + (Essentials + Base_Disp) ideally.
    % So stack_data rows should sum roughly to Gross (or very close).
    stack_data = [ [metrics.Tax_Monthly]', [metrics.Essential_Monthly]', [metrics.Base_Disp_Monthly]' ];
    
    % Normalize to percentage of the SUM of these components (which creates a clean 100% bar)
    % This handles cases where Base_Disp was clamped to 0 but debt isn't shown in the stack itself.
    bar_data = stack_data ./ sum(stack_data, 2) * 100;
    
    b = bar(bar_data, 'stacked');
    b(1).FaceColor = [0.6 0.6 0.6]; % Gray for Tax
    b(2).FaceColor = [0.8 0.2 0.2]; % Deep Red for Essentials
    b(3).FaceColor = [0.2 0.6 0.2]; % Green for Disposable
    
    set(gca, 'XTickLabel', {metrics.Label}, 'XTickLabelRotation', 45, 'FontSize', 10);
    ylabel('Percentage of Income (%)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Exhibit 1: Proportional Income Burden', 'FontSize', 12, 'FontWeight', 'bold');
    legend({'Taxes', 'Essentials', 'Disposable Income'}, 'Location', 'eastoutside');
    yline(50, 'k--', 'LineWidth', 1.5, 'Label', '50% Threshold'); 
    ylim([0 100]);
    grid on;

    % --- Exhibit 2: Fat Tail Risk (Persona 6) ---
    nexttile;
    hold on;
    % Kernel Density Estimate
    [f, xi] = ksdensity(p6_sim_data);
    
    % Shade the "Debt Zone" (x < 0)
    debt_indices = xi < 0;
    if any(debt_indices)
        % Fill area under curve for x < 0
        fill([xi(debt_indices) 0], [f(debt_indices) 0], [1 0.8 0.8], 'EdgeColor', 'none', 'DisplayName', 'Debt Zone');
    end
    
    % Plot the density line
    plot(xi, f, 'LineWidth', 2, 'Color', 'k', 'DisplayName', 'Income Distribution');
    
    % Add vertical line at x=0
    xline(0, 'r--', 'LineWidth', 2, 'Label', 'Zero Balance');
    
    xlabel('Monthly Disposable Income ($)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Probability Density', 'FontSize', 11, 'FontWeight', 'bold');
    title({'Exhibit 2: Fat Tail Risk Distribution', '(Persona 6: Low Income US)'}, 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northeast');
    grid on;
    xlim([min(xi) max(xi)*1.1]);
    box on;
    hold off;

    % --- Exhibit 3: Vulnerability (Grouped Bar) ---
    nexttile;
    % Grouped: [Base Monthly, Worst 5th %]
    vuln_data = [ [metrics.Base_Disp_Monthly]', [metrics.Worst_5th_Month]' ];
    b3 = bar(vuln_data, 'grouped');
    b3(1).FaceColor = [0.2 0.4 0.8]; % Blue
    b3(2).FaceColor = [0.8 0.4 0.2]; % Orange/Red
    
    set(gca, 'XTickLabel', {metrics.Label}, 'XTickLabelRotation', 45, 'FontSize', 10);
    ylabel('Monthly Income ($)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Exhibit 3: Vulnerability by Demographic', 'FontSize', 12, 'FontWeight', 'bold');
    legend({'Base Monthly Income', 'Worst 5th Percentile Month'}, 'Location', 'best');
    yline(0, 'k-', 'LineWidth', 1.5);
    grid on;

    % --- Exhibit 4: Probability of Ruin ---
    nexttile;
    % Line chart
    probs = [metrics.Prob_Debt]';
    x = 1:num_personas;
    
    % Plot line
    plot(x, probs, '-o', 'LineWidth', 2, 'Color', 'b', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
    hold on;
    % Highlight P6 with red asterisk
    plot(6, probs(6), 'r*', 'MarkerSize', 15, 'LineWidth', 3);
    
    set(gca, 'XTick', 1:num_personas, 'XTickLabel', {metrics.Label}, 'XTickLabelRotation', 45, 'FontSize', 10);
    ylabel('Probability of Neg. Income (%)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Exhibit 4: Baseline Probability of Ruin', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    ylim([0 max(probs)*1.2]); % Give some headroom
    
    % Add data labels for clarity
    text(x, probs, string(round(probs,1))+"%", 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 9);

    hold off;
    
end

function [simulated_monthly_incomes] = replicate_shock_simulation_outcome(monthly_disposable_income, age, country, adults, children, num_sims)
    % Replicates logic of simulate_monthly_shocks to return raw array
    
    % Step A: Severity Parameters (Log-Normal Distribution)
    country = upper(string(country)); % Ensure string comparison works
    if strcmpi(country, 'US')
        mu = 7.6;
        sigma = 0.8;
    elseif strcmpi(country, 'UK')
        mu = 6.48;
        sigma = 0.75;
    else
        % Default fallback if unknown (should rely on caller to be correct)
         mu = 7.6; sigma=0.8;
    end
    
    % Step B: Frequency Parameter (Poisson Distribution)
    base_lambda_monthly = 0.0763;
    
    if age > 40
        age_mod = 1.2;
    else
        age_mod = 1.0;
    end
    
    size_mod = 1.0 + 0.2 * ((adults + children) - 1);
    lambda_monthly = base_lambda_monthly * age_mod * size_mod;
    
    % Step C: Monte Carlo Simulation
    simulated_monthly_incomes = zeros(num_sims, 1);
    
    % Generate number of events
    N = poissrnd(lambda_monthly, num_sims, 1);
    
    for i = 1:num_sims
        if N(i) == 0
            shock_cost = 0;
        else
            % Draw N(i) random samples
            shock_cost = sum(lognrnd(mu, sigma, N(i), 1));
        end
        simulated_monthly_incomes(i) = monthly_disposable_income - shock_cost;
    end
end

