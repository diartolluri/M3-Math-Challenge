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
        
        % 2. Income Tax Brackets (2024/25)
        if strcmpi(persona.Region, 'Scotland')
            % Scotland 2024-25 Income Tax (taxable income ranges)
            % Starter: 19% on £1 - £2,297
            % Basic: 20% on £2,298 - £13,991
            % Intermediate: 21% on £13,992 - £31,092
            % Higher: 42% on £31,093 - £62,430
            % Advanced: 45% on £62,431 - £125,140
            % Top: 48% over £125,140
            limits = [2297, 13991, 31092, 62430, 125140, inf];
            rates  = [0.19, 0.20, 0.21, 0.42, 0.45, 0.48];
        else
            % Rest of UK (England, Wales, NI) 2024-25 Income Tax
            % Basic: 20% on £1 - £37,700
            % Higher: 40% on £37,701 - £125,140
            % Additional: 45% over £125,140
            limits = [37700, 125140, inf];
            rates  = [0.20, 0.40, 0.45];
        end
        
        income_tax = 0;
        prev_limit = 0;
        for i = 1:length(rates)
            if taxable_income > prev_limit
                taxable_in_bracket = min(taxable_income, limits(i)) - prev_limit;
                income_tax = income_tax + (taxable_in_bracket * rates(i));
                prev_limit = limits(i);
            else
                break;
            end
        end
        
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
