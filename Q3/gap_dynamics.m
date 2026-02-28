function dDelta = gap_dynamics(t, Delta, q, a, w, b, r, id)
    % gap_dynamics defines the differential equations for the financial gaps.
    % State variables:
    % Delta(1) = Delta_A (Savings gap)
    % Delta(2) = Delta_W (Wealth gap)
    % Delta(3) = Delta_B (Debt gap)
    
    dDelta = zeros(3, 1);
    
    % Savings gap grows from cash drained now
    dDelta(1) = a * q;
    
    % Wealth gap grows from missed investing plus lost compounding
    dDelta(2) = r * Delta(2) + w * q;
    
    % Debt gap grows from new borrowing plus interest
    dDelta(3) = id * Delta(3) + b * q;
end
