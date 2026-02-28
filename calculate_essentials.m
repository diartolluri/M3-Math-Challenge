function base_essentials = calculate_essentials(persona, cost_data)
% CALCULATE_ESSENTIALS Estimates baseline single-adult essential costs via table
% lookups from empirical cost data.
%
% Inputs:
%   persona   : Struct with fields (Salary, Age, Country, Region, Adults, Children)
%   cost_data : MATLAB table loaded from essential_costs.csv 
%
% Output:
%   base_essentials : Baseline essential costs for a single adult.

    % Filter the cost_data table to match the persona.Country and persona.Region
    is_cc = strcmpi(string(cost_data.Country), string(persona.Country));
    is_rr = strcmpi(string(cost_data.Region), string(persona.Region));
    
    match_row = cost_data(is_cc & is_rr, :);
    
    if isempty(match_row)
        error('calculate_essentials:NotFound', ...
            'Could not find matching cost data for Country: %s, Region: %s', ...
            persona.Country, persona.Region);
    end
    
    % If there are multiple matches, take the first one
    match_row = match_row(1, :);
    
    % Extract the annual base costs
    Base_Housing    = match_row.Base_Housing_Annual;
    Base_Food       = match_row.Base_Food_Annual;
    Base_Transport  = match_row.Base_Transport_Annual;
    Base_Healthcare = match_row.Base_Healthcare_Annual;
    
    % Healthcare Age Scaling:
    % If persona.Age > 65 and Country == 'US', multiply Base_Healthcare by 2.5
    if persona.Age > 65 && strcmpi(persona.Country, 'US')
        Base_Healthcare = Base_Healthcare * 2.5;
    end
    
    % Compute Total Base Essentials for a Single Adult
    base_essentials = Base_Housing + Base_Food + Base_Transport + Base_Healthcare;
end
    
end
