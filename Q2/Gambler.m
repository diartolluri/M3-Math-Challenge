classdef Gambler < handle
    properties
        Age
        Gender
        Country
        DisposableIncome
        BaseRiskTolerance
        CurrentRiskTolerance
        ChasingCoefficient
        NetProfit
        BetHistory
        ProfitHistory
    end
    
    methods
        function self = Gambler(age, gender, country, disposableIncome, chasingCoeff)
            if nargin < 5
                chasingCoeff = 1.2; % Default chasing coefficient > 1
            end
            self.Age = age;
            self.Gender = gender;
            self.Country = country;
            self.DisposableIncome = disposableIncome;
            self.ChasingCoefficient = chasingCoeff;
            self.NetProfit = 0;
            self.BetHistory = [];
            self.ProfitHistory = [];
            
            % Formula provided: 3.068 + 0.987(Age) - 0.037(Age^2)
            score = 54.0832 + 1.5402 * self.Age -0.0329 * (self.Age^2);
            % Convert the resulting score to a probability / risk measurement [0, 1]
            if self.Gender == "Male"
                score = 53.5213 + 1.9007 * self.Age -0.0405 * (self.Age^2);
            end
            score = score / 100;
            self.BaseRiskTolerance = max(0.01, min(1, score)); % minimum floor of 1%
            self.CurrentRiskTolerance = self.BaseRiskTolerance;
        end

        function [risk_level, win_prob, payout_multiplier] = determine_bet_profile(self)
            % Incorporate risk tolerance and disposable income into a risk profile
            % Average US disposable income ~40,000 for relative scaling
            income_factor = max(2.0, min(0.5, self.DisposableIncome / 40000));
            effective_risk = self.CurrentRiskTolerance * income_factor;
            
            % Map to defined profiles based on empirical thresholds
            if effective_risk < 0.08
                % Low Risk (Straight Bets)
                risk_level = "Low";
                win_prob = 0.50;
                payout_multiplier = 0.909;
            elseif effective_risk < 0.15
                % Average Risk (Mixed Portfolio)
                risk_level = "Average";
                win_prob = 0.45;
                payout_multiplier = 1.0;
            else
                % High Risk (Parlays)
                risk_level = "High";
                win_prob = 0.10;
                payout_multiplier = 7.0;
            end
        end

        function profit = place_bet(self, bet_amount)
            [~, win_prob, payout_multiplier] = self.determine_bet_profile();
            
            % Simulate outcome
            is_win = rand() < win_prob;
            
            if is_win
                % Gambler wins
                profit = bet_amount * payout_multiplier;
                self.NetProfit = self.NetProfit + profit;
                
                % Reset risk tolerance back to original value (Markov Chain restart)
                self.CurrentRiskTolerance = self.BaseRiskTolerance;
            else
                % Gambler loses
                profit = -bet_amount;
                self.NetProfit = self.NetProfit + profit;
                
                % Chase losses: multiply risk tolerance by a chasing coefficient > 1
                self.CurrentRiskTolerance = min(1.0, self.CurrentRiskTolerance * self.ChasingCoefficient);
            end
        end

        function simulate_year(self, bettingFreq)
            self.BetHistory = zeros(12, 1);
            self.ProfitHistory = zeros(12, 1);
            base_bet_amount = 0.001 * self.DisposableIncome;
            max_bet = self.DisposableIncome * 0.05;

            for i = 1:12
                for f = 1:bettingFreq

                    total_profit = 0;
                    betting = true;

                    while betting
                        bet_amount = base_bet_amount * (self.CurrentRiskTolerance / self.BaseRiskTolerance);
                        bet_amount = min(bet_amount, max_bet);
                        outcome = self.place_bet(bet_amount);
                        total_profit = total_profit + outcome;
                        out = rand();
                        betting = self.CurrentRiskTolerance > out && total_profit > -max_bet;
                    end

                    self.NetProfit = self.NetProfit + total_profit;
                end
                % Bet size scales with risk tolerance, capped at 5% of disposable income
                
                
                
                self.ProfitHistory(i) = self.NetProfit;
            end
        end
    end
end