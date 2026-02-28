function Net_Income = calculate_taxes(persona)
% CALCULATE_TAXES Computes exact post-tax net income based on 
% 2024 U.S. and U.K. statutory tax brackets.
%
% Inputs:
%   persona : Struct containing demographic and gross salary data
%             (Salary, Age, Country, Region, Adults, Children)
%
% Outputs:
%   Net_Income : Final post-tax Net Income

    % Initialize Gross Salary
    Salary = persona.Salary;
    Country = persona.Country;
    
    if strcmpi(Country, 'US')
        % --- US Tax Calculation ---
        
        % 1. Standard Deduction
        if persona.Adults > 1
            std_deduction = 29200; % Married standard deduction
        else
            std_deduction = 14600; % Single standard deduction
        end
        
        taxable_income = max(Salary - std_deduction, 0);
        
        % 2. 2024 Progressive Marginal Tax Brackets
        % Hardcoded the 10%, 12%, 22%, 24%, 32%, 35%, 37% brackets
        if persona.Adults > 1
            % Married Filing Jointly limits
            brackets = [23200, 94300, 201050, 383900, 487450, 760400, inf];
        else
            % Single limits
            brackets = [11600, 47150, 100525, 191950, 243725, 609350, inf];
        end
        rates = [0.10, 0.12, 0.22, 0.24, 0.32, 0.35, 0.37];
        
        federal_tax = 0;
        prev_limit = 0;
        for i = 1:length(rates)
            if taxable_income > prev_limit
                taxable_in_bracket = min(taxable_income, brackets(i)) - prev_limit;
                federal_tax = federal_tax + (taxable_in_bracket * rates(i));
                prev_limit = brackets(i);
            else
                break;
            end
        end
        
        % 3. FICA (Payroll Tax)
        ss_tax = min(Salary, 168600) * 0.062; % Social Security
        medicare_tax = Salary * 0.0145;       % Medicare
        fica_tax = ss_tax + medicare_tax;
        
        % 4. State Tax
        % Look up in us_state_taxes.csv / tax_rates.csv
        state_tax = 0;
        
        persistent state_data;
        if isempty(state_data)
            if exist('us_state_taxes.csv', 'file')
                state_data = readtable('us_state_taxes.csv', 'VariableNamingRule', 'preserve');
            elseif exist('tax_rates.csv', 'file')
                state_data = readtable('tax_rates.csv', 'VariableNamingRule', 'preserve');
            else
                error('calculate_taxes:MissingData', 'Could not finding state tax data file.');
            end
        end
        
        % Try to find region match
        is_rr = strcmpi(string(state_data.Region), string(persona.Region));
        if any(is_rr)
            match_row = state_data(is_rr, :);
            effective_rate = match_row.Effective_State_Tax_Rate(1);
            state_tax = Salary * effective_rate;
        end
        
        % Net Income US
        Net_Income = Salary - (federal_tax + fica_tax + state_tax);
        
    elseif strcmpi(Country, 'UK')
        % --- UK Tax Calculation ---
        
        % 1. Personal Allowance
        % Reduce by £1 for every £2 earned over £100,000
        reduction = max(0, (Salary - 100000) / 2);
        pa = max(0, 12570 - reduction);
        
        taxable_income = max(Salary - pa, 0);
        
        % 2. Income Tax Brackets
        % 20% on first 37,700 of taxable income (which translates to £12,571 to £50,270 when PA is unbroken)
        % 40% up to 125,140 gross (translates to 125,140 - PA in taxable income)
        % 45% on gross > 125,140
        tax20 = 0.20 * min(taxable_income, 37700);
        
        % Higher rate limit is gross 125140, which means 125140 - pa of taxable income.
        higher_rate_limit = 125140 - pa;
        tax40 = 0.40 * max(0, min(taxable_income, higher_rate_limit) - 37700);
        
        tax45 = 0.45 * max(0, taxable_income - higher_rate_limit);
        
        income_tax = tax20 + tax40 + tax45;
        
        % 3. National Insurance (Class 1)
        % 0% up to £12,570; 8% between £12,570 and £50,270; 2% above £50,270
        ni_8 = 0.08 * max(0, min(Salary, 50270) - 12570);
        ni_2 = 0.02 * max(0, Salary - 50270);
        
        NI = ni_8 + ni_2;
        
        % Net Income UK
        Net_Income = Salary - (income_tax + NI);
        
    else
        error('calculate_taxes:UnknownCountry', ...
            'Country "%s" not supported.', Country);
    end

end
<<<<<<< Updated upstream
=======

% ==================== LOCAL FUNCTIONS ====================

function net_income = calculate_us_taxes(p, stateTaxTable)
%CALCULATE_US_TAXES Compute net income after US taxes.
%   Input:
%       p - persona struct with fields: GrossSalary, Region, Adults
%       stateTaxTable - table with state tax rates
%   Output:
%       net_income - net income after all US taxes

    % Determine filing status based on number of adults
    % Married Filing Jointly if 2+ adults, otherwise Single
    isMarried = (p.Adults >= 2);
    
    % Standard deduction: $12,950 per adult (2024 IRS amount)
    % Married couples get double the standard deduction
    if isMarried
        standardDeduction = 12950 * 2;  % $25,900 for married filing jointly
    else
        standardDeduction = 12950;  % $12,950 for single
    end
    taxableIncome = max(p.GrossSalary - standardDeduction, 0);
    
    % Federal tax brackets for 2024
    % Single: [0 11000 44725 95375 182100 231250 578125]
    % Married Filing Jointly: [0 22000 89450 190750 364200 462500 693750]
    if isMarried
        brackets = [0 22000 89450 190750 364200 462500 693750];
    else
        brackets = [0 11000 44725 95375 182100 231250 578125];
    end
    rates    = [0.10 0.12 0.22 0.24 0.32 0.35 0.37];
    fedTax = 0;
    for b = 1:numel(brackets)-1
        lower = brackets(b);
        upper = brackets(b+1);
        if taxableIncome > lower
            portion = min(taxableIncome, upper) - lower;
            fedTax = fedTax + portion * rates(b);
        end
    end
    
    % FICA taxes
    % Social Security: 6.2% up to wage base ($168,600 for 2024)
    ssCap = 168600;
    ssTax = min(p.GrossSalary, ssCap) * 0.062;
    
    % Medicare: 1.45% on all income
    % Additional Medicare Tax: 0.9% on income over $200k (single) / $250k (married)
    medicareTax = p.GrossSalary * 0.0145;
    if isMarried
        if p.GrossSalary > 250000
            medicareTax = medicareTax + (p.GrossSalary - 250000) * 0.009;
        end
    else
        if p.GrossSalary > 200000
            medicareTax = medicareTax + (p.GrossSalary - 200000) * 0.009;
        end
    end
    ficaTax = ssTax + medicareTax;
    
    % State tax lookup with progressive brackets for major states
    stateCode = string(p.Region);
    
    % Define states with progressive brackets (brackets and rates)
    % Format: brackets (threshold values), rates (corresponding rates)
    stateBrackets = containers.Map();
    
    % California progressive brackets (2024)
    stateBrackets('CA') = struct('brackets', [0 10412 24684 38959 54081 68350 349137], ...
                                   'rates', [0.01 0.02 0.04 0.06 0.08 0.093 0.103]);
    
    % New York progressive brackets (2024)
    stateBrackets('NY') = struct('brackets', [0 8500 11700 13900 80650 215400 1077550], ...
                                   'rates', [0.04 0.045 0.0525 0.055 0.06 0.0685 0.0965]);
    
    % Check if state has progressive brackets
    if isKey(stateBrackets, stateCode)
        s = stateBrackets(stateCode);
        
        % Apply state-specific standard deductions
        if strcmp(stateCode, 'CA')
            % California standard deductions (2024)
            if isMarried
                stateDeduction = 9606;
            else
                stateDeduction = 4803;
            end
        elseif strcmp(stateCode, 'NY')
            % New York standard deductions (2024)
            if isMarried
                stateDeduction = 16050;
            else
                stateDeduction = 8000;
            end
        else
            stateDeduction = 0;
        end
        
        % Calculate state taxable income (using state-specific deduction, not federal)
        stateTaxableIncome = max(p.GrossSalary - stateDeduction, 0);
        
        stateTax = 0;
        for b = 1:numel(s.brackets)-1
            lower = s.brackets(b);
            upper = s.brackets(b+1);
            if stateTaxableIncome > lower
                portion = min(stateTaxableIncome, upper) - lower;
                stateTax = stateTax + portion * s.rates(b);
            end
        end
    else
        % Use flat rate for other states
        stateIdx = find(stateTaxTable.State == stateCode, 1);
        if isempty(stateIdx)
            warning('State %s not found in us_state_taxes.csv; assuming 0%% state tax.', p.Region);
            stateRate = 0;
        else
            stateRate = stateTaxTable.Rate(stateIdx);
        end
        stateTax = taxableIncome * stateRate;
    end
    
    totalTax = fedTax + ficaTax + stateTax;
    net_income = p.GrossSalary - totalTax;

end

function net_income = calculate_uk_taxes(p)
%CALCULATE_UK_TAXES Compute net income after UK taxes.
%   Input:
%       p - persona struct with field: GrossSalary
%   Output:
%       net_income - net income after all UK taxes

% Personal allowance £12,570 reduced by £1 per £2 over £100,000
    allowance = 12570;
    if p.GrossSalary > 100000
        reduction = floor((p.GrossSalary - 100000) / 2);
        allowance = max(allowance - reduction, 0);
    end
    taxableIncome = max(p.GrossSalary - allowance, 0);
    
    % Income tax brackets (2024/25 rates)
    ukBrackets = [0 50270 150000];
    ukRates    = [0.20 0.40 0.45];
    incomeTax = 0;
    for b = 1:numel(ukBrackets)-1
        lower = ukBrackets(b);
        upper = ukBrackets(b+1);
        if taxableIncome > lower
            portion = min(taxableIncome, upper) - lower;
            incomeTax = incomeTax + portion * ukRates(b);
        end
    end
    
    % National Insurance (2024/25 rates)
    if p.GrossSalary <= 12570
        niTax = 0;
    elseif p.GrossSalary <= 50270
        niTax = (p.GrossSalary - 12570) * 0.08;
    else
        niTax = (50270 - 12570) * 0.08 + (p.GrossSalary - 50270) * 0.02;
    end
    
    totalTax = incomeTax + niTax;
    net_income = p.GrossSalary - totalTax;

end
>>>>>>> Stashed changes
