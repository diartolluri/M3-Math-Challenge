function [results] = simulate_monthly_shocks(monthly_disposable_income, age, country, adults, children, num_sims)
% SIMULATE_MONTHLY_SHOCKS Simulates the impact of random financial shocks 
% using a Frequency-Severity actuarial framework.
%
% Inputs:
%   monthly_disposable_income - Baseline monthly disposable income
%   age                       - Age of the primary earner
%   country                   - Country of residence ('US' or 'UK')
%   adults                    - Number of adults in the household
%   children                  - Number of children in the household
%   num_sims                  - (Optional) Number of simulations to run. Default: 10000.
%
% Outputs:
%   results.Base_Monthly_Income        - Deterministic monthly disposable income
%   results.Median_Monthly_Income      - Median of simulated monthly incomes
%   results.Worst_5th_Percentile_Month - 5th percentile of simulated monthly incomes
%   results.Prob_of_Debt_Percent       - Percentage of simulations resulting in debt

    % Set default number of simulations if not provided
    if nargin < 6 || isempty(num_sims)
        num_sims = 10000;
    end

    %% Step A: Determine Severity Parameters (Log-Normal Distribution)
    country = upper(country); % Ensure case-insensitivity
    if strcmp(country, 'US')
        mu = 7.6;
        sigma = 0.8;
    elseif strcmp(country, 'UK')
        mu = 6.48;
        sigma = 0.75;
    else
        error('Invalid country. Must be ''US'' or ''UK''.');
    end

    %% Step B: Determine Frequency Parameter (Poisson Distribution)
    base_lambda_monthly = 0.0763;
    
    % Calculate age_mod
    if age > 40
        age_mod = 1.2;
    else
        age_mod = 1.0;
    end
    
    % Calculate size_mod
    size_mod = 1.0 + 0.2 * ((adults + children) - 1);
    
    % Final monthly lambda
    lambda_monthly = base_lambda_monthly * age_mod * size_mod;

    %% Step C: The Monte Carlo Simulation (Vectorized for Speed)
    % Initialize an array simulated_monthly_incomes of size num_sims x 1
    simulated_monthly_incomes = zeros(num_sims, 1);
    
    % Generate the number of emergency events for all universes at once
    N = poissrnd(lambda_monthly, num_sims, 1);
    
    for i = 1:num_sims
        if N(i) == 0
            shock_cost = 0;
        elseif N(i) > 0
            % Draw N(i) random samples from Log-Normal and sum them
            shock_cost = sum(lognrnd(mu, sigma, N(i), 1));
        end
        simulated_monthly_incomes(i) = monthly_disposable_income - shock_cost;
    end

    %% Step D: Return Risk Metrics
    % Store the results in a struct
    results.Base_Monthly_Income = monthly_disposable_income;
    results.Median_Monthly_Income = median(simulated_monthly_incomes);
    results.Worst_5th_Percentile_Month = prctile(simulated_monthly_incomes, 5);
    
    % Calculate probability of debt as a percentage
    prob_debt = sum(simulated_monthly_incomes < 0) / num_sims;
    results.Prob_of_Debt_Percent = prob_debt * 100;

end
