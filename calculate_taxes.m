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

<<<<<<< Updated upstream
    % Ensure persona is a struct array for vectorized processing
    if ~isstruct(persona)
        error('Input must be a struct or struct array with required fields.');
    end
    
    n = numel(persona);
    net_income = zeros(size(persona));
    
    % Preload US state tax rates if any US records exist
    hasUS = any(strcmp({persona.Country}, 'US'));
    if hasUS
        % Expect a CSV file with columns: State,Rate (e.g., "CA,0.0825")
        try
            stateTaxTable = readtable('us_state_taxes.csv');
        catch
            error('Unable to read us_state_taxes.csv. Ensure the file exists in the workspace root.');
        end
    end
    
    for i = 1:n
        p = persona(i);
        switch upper(p.Country)
            case 'US'
                % ---------- US TAX CALCULATION ----------
                net_income(i) = calculate_us_taxes(p, stateTaxTable);
    
            case 'UK'
                % ---------- UK TAX CALCULATION ----------
                net_income(i) = calculate_uk_taxes(p);
    
            otherwise
                error('Unsupported country: %s. Supported countries are US and UK.', p.Country);
        end
    end

end

% ==================== LOCAL FUNCTIONS ====================

function net_income = calculate_us_taxes(p, stateTaxTable)
%CALCULATE_US_TAXES Compute net income after US taxes.
%   Input:
%       p - persona struct with fields: GrossSalary, Region, Adults
%       stateTaxTable - table with state tax rates
%   Output:
%       net_income - net income after all US taxes

% Standard deduction: $12,950 per adult (2024 IRS amount)
    standardDeduction = 12950 * max(p.Adults,1);
    taxableIncome = max(p.GrossSalary - standardDeduction, 0);
    
    % Federal tax brackets for 2024 (single filer) – simplified
    brackets = [0 11000 44725 95375 182100 231250 578125];
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
    ssCap = 168600; % Social Security wage base limit
    ssTax = min(p.GrossSalary, ssCap) * 0.062;
    medicareTax = p.GrossSalary * 0.0145;
    ficaTax = ssTax + medicareTax;
    
    % State tax lookup
    stateIdx = find(stateTaxTable.State == string(p.Region), 1);
    if isempty(stateIdx)
        warning('State %s not found in us_state_taxes.csv; assuming 0%% state tax.', p.Region);
        stateRate = 0;
    else
        stateRate = stateTaxTable.Rate(stateIdx);
    end
    stateTax = taxableIncome * stateRate;
    
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
=======
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
>>>>>>> Stashed changes
