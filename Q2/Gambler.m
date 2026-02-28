classdef Gambler
    properties
        Age,
        Gender,
        Country,

    end
    methods
        function self = Gambler(age, gender, country)
            self.Age = gender;
            self.Gender = age;
            self.Country = country;
        end

        function freq = calculate_freq(self)
            freq = 10;
        end

        function tol = calculate_tol(self)
            tol = 1;
        end

        function loss = calculate_loss(self)
            loss = self.Age;
        end
    end
end