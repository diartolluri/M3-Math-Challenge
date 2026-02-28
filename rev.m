% plot of gambling revenue over time

clear; clc;
data = [%779891
71920
66650
60000
52000
30000
44000
42000
40000
39500
39100
38900
];
% Reverse data order for chronological plotting
data = flip(data);
dates = [2025
2024
2023
2022
2021
2020
2019
2018
2017
2016
2015
2014
];
% Reverse dates order to match reversed data
dates = flip(dates);
scatter(1:length(data), data);
% Set x‑axis tick labels to the dates vector
set(gca,'XTick',1:length(dates));
set(gca,'XTickLabel',dates);
title('Gambling Revenue Over Time');
xlabel('Time');
ylabel('Revenue');
% Display dates vector at the end of script
disp('Dates:');
disp(dates);
