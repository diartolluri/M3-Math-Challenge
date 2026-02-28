function total_household_essentials = calculate_essentials(persona, cost_data)
%CALCULATE_ESSENTIALS Compute total household essential costs.
%   total_household_essentials = CALCULATE_ESSENTIALS(persona, cost_data)
%
% INPUTS:
%   persona   - struct or struct array with fields:
%               .Country (string), .Region (string), .Age (numeric)
%   cost_data - table containing cost information. Must include columns:
%               Country, Region, Base_Housing_Annual, Base_Food_Annual,
%               Base_Transport_Annual, Base_Healthcare_Annual
%
% OUTPUT:
%   total_household_essentials - numeric array matching size of persona,
%                               containing the summed essential costs.
%
% The function filters cost_data for each persona's Country and Region,
% extracts the four base cost columns, applies a healthcare multiplier for
% seniors in the US, and sums the values. Errors are thrown if required data
% is missing.

% Validate inputs
if ~isstruct(persona)
    error('persona must be a struct or struct array');
end
requiredPersonaFields = {'Country','Region','Age'};
for f = requiredPersonaFields
    if ~isfield(persona, f{1})
        error('persona is missing required field: %s', f{1});
    end
end
requiredCostCols = {'Base_Housing_Annual','Base_Food_Annual',...
    'Base_Transport_Annual','Base_Healthcare_Annual'};
missingCols = setdiff(requiredCostCols, cost_data.Properties.VariableNames);
if ~isempty(missingCols)
    error('cost_data missing required columns: %s', strjoin(missingCols, ', '));
end

% Preallocate output
n = numel(persona);
total_household_essentials = zeros(n,1);

for i = 1:n
    % Extract matching rows
    country = persona(i).Country;
    region  = persona(i).Region;
    age     = persona(i).Age;
    rows = cost_data(cost_data.Country == country & cost_data.Region == region, :);
    if isempty(rows)
        error('No cost data found for Country=%s, Region=%s', string(country), string(region));
    end
    % Use first matching row (assuming unique per Country/Region)
    row = rows(1,:);
    housing   = row.Base_Housing_Annual;
    food      = row.Base_Food_Annual;
    transport = row.Base_Transport_Annual;
    healthcare= row.Base_Healthcare_Annual;
    % Adjust healthcare for seniors in US
    if age > 65 && strcmpi(string(country), 'US')
        healthcare = healthcare * 2.5;
    end
    total_household_essentials(i) = housing + food + transport + healthcare;
end

% Ensure column vector output
if isrow(total_household_essentials)
    total_household_essentials = total_household_essentials.';
end

end