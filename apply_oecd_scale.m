function Individual_Essentials = apply_oecd_scale(base_essentials, adults, children)
% APPLY_OECD_SCALE Converts base single-adult essential costs to an
% individual's share of total household costs using the OECD-modified scale.
%
%   EQ = 1.0 + 0.5 * (adults - 1) + 0.3 * children
%   Total_Household = base_essentials * EQ
%   Individual_Essentials = Total_Household / adults
%
% Inputs:
%   base_essentials      : Baseline essential costs for a single adult (numeric)
%   adults               : Number of adults in the household (numeric, min 1)
%   children             : Number of dependents in the household (numeric)
%
% Outputs:
%   Individual_Essentials: Individual portion of the essential costs

    % Ensure adults is at least 1
    adults = max(1, adults);
    
    % Calculate OECD-modified equivalence scale factor (EQ)
    EQ = 1.0 + 0.5 * (adults - 1) + 0.3 * children;
    
    % Calculate individual's portion of the essential costs
    % First, scale base costs up to the household level, then divide by adults
    % assuming adults share expenses equally.
    Total_Household_Costs = base_essentials * EQ;
    Individual_Essentials = Total_Household_Costs / adults;
end
