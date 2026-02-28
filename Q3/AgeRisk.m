% Enter midpoints of age bins
age = [10.5 12.5 14.5 16.5 18.5 20.5 22.5 24.5 26.5 28.5];

% Enter the corresponding Table 3 BART means here
bart_mean_f = [ 65.73, 68.66, 70.00, 71.58, 70.68, 72.36, 70.89, 71.34, 72.18, 71.68 ];   % <-- paste actual percentages
bart_mean = [68.70, 71.37, 71.93, 74.20, 75.70, 75.52, 75.85, 74.27, 75.53, 75.41];
% Fit quadratic
p = polyfit(age, bart_mean, 2);

% Quadratic equation:
% y = p(1)*Age^2 + p(2)*Age + p(3)

disp(p)