% apply_oecd_scale.m
% Computes individual essential consumption using the OECD-modified equivalence scale.
%
% Syntax:
%   individual_essentials = apply_oecd_scale(household_essentials, adults, children)
%
% Inputs:
%   household_essentials - Numeric array or scalar of total household essential consumption.
%   adults               - Number of adults in the household (must be >= 1). Can be scalar or array.
%   children             - Number of children in the household (must be >= 0). Can be scalar or array.
%
% Output:
%   individual_essentials - Household essentials divided by the equivalence scale factor.
%
% The OECD-modified equivalence scale factor is defined as:
%   EQ = 1.0 + 0.5*(adults-1) + 0.3*children
% This function supports scalar inputs as well as vectorized calls where the inputs are arrays of the same size.
%
% Example:
%   apply_oecd_scale(20000, [2 3], [1 2])
%   % Returns [13333.33 12500]
%
function individual_essentials = apply_oecd_scale(household_essentials, adults, children)
    %% Input validation
    if ~isnumeric(household_essentials) || ~isnumeric(adults) || ~isnumeric(children)
        error('All inputs must be numeric.')
    end
    if any(adults < 1)
        error('Number of adults must be at least 1 for all observations.')
    end
    if any(children < 0)
        error('Number of children cannot be negative.')
    end
    % Ensure inputs are compatible for element‑wise operations
    try
        % Attempt broadcasting using implicit expansion (MATLAB R2016b+)
        EQ = 1.0 + 0.5 .* (adults - 1) + 0.3 .* children;
        individual_essentials = household_essentials ./ EQ;
    catch ME
        error('Input size mismatch: %s', ME.message);
    end
end