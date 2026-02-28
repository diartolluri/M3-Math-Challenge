function Individual_Essentials = apply_oecd_scale(household_essentials, adults, children)
% APPLY_OECD_SCALE Converts household costs to individual costs
% using the OECD-modified equivalence scale factor (EQ).
%
%   EQ = 1.0 + 0.5 * (adults - 1) + 0.3 * children
%   Individual_Essentials = household_essentials / EQ
%
% Inputs:
%   household_essentials : Total household essential costs (numeric)
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
    Individual_Essentials = household_essentials / EQ;
end
