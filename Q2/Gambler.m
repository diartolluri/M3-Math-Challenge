classdef Gambler
    properties
        Age,
    end
    methods
        function loss = calculate_loss(self)
            loss = self.Age;
        end
    end
end