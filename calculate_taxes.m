function net_income = calculate_taxes(persona)
%CALCULATE_TAXES Compute net income after taxes for US and UK personas.
%   persona is a struct (or array of structs) with fields:
%       .Country   - 'US' or 'UK'
%       .Region    - State abbreviation for US (e.g., 'CA')
%       .GrossSalary - Annual gross salary (numeric, USD for US, GBP for UK)
%       .Adults    - Number of adults in household (used for US standard deduction)
%
%   The function returns net_income, matching the size of persona.
%
%   Example:
%       p.Country = 'US';
%       p.Region = 'CA';
%       p.GrossSalary = 85000;
%       p.Adults = 2;
%       net = calculate_taxes(p);
%
%   Author: Kilo Code
%   Date: 2026-02-28

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
            net_income(i) = p.GrossSalary - totalTax;

        case 'UK'
            % ---------- UK TAX CALCULATION ----------
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
            net_income(i) = p.GrossSalary - totalTax;

        otherwise
            error('Unsupported country: %s. Supported countries are US and UK.', p.Country);
    end
end

end