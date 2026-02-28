% plot of gambling revenue over time

clear; clc;
data = [
8365
8116
8436
9027
9705
9869
11314
13456
13780
14411
14367
14187
12670
14153
15127
15629
16778
];
dates = ["Apr 2008 - Mar 2009"
"Apr 2009 - Mar 2010"
"Apr 2010 - Mar 2011"
"Apr 2011 - Mar 2012"
"Apr 2012 - Mar 2013"
"Apr 2013 - Mar 2014"
"Apr 2014 - Mar 2015"
"Apr 2015 - Mar 2016"
"Apr 2016 - Mar 2017"
"Apr 2017 - Mar 2018"
"Apr 2018 - Mar 2019"
"Apr 2019 - Mar 2020"
"Apr 2020 - Mar 2021"
"Apr 2021 - Mar 2022"
"Apr 2022 - Mar 2023"
"Apr 2023 - Mar 2024"
"Apr 2024 - Mar 2025"
];
scatter(1:length(data), data);
% Set x‑axis tick labels to the dates vector
set(gca,'XTick',1:length(dates));
set(gca,'XTickLabel',dates);
title('Gambling Revenue Over Time');
xlabel('Time');
ylabel('Revenue');