function RBM = calculate_RBM(months, g_monthly, s_monthly, c_monthly, a, w, b, r_annual, id_annual, M, C_rep)
    % calculate_RBM calculates the Recovery Burden Months (RBM)
    % 
    % Inputs:
    %   months     - simulation time in months
    %   g_monthly  - gambling loss
    %   s_monthly  - stress/leakage cost
    %   c_monthly  - safe cushion
    %   a, w, b    - shares allocated to savings, wealth, debt (a+w+b=1)
    %   r_annual   - annual investment return
    %   id_annual  - annual debt interest rate
    %   M          - milestone-delay cost
    %   C_rep      - normal monthly saving capacity
    %
    % Output:
    %   RBM - Recovery Burden Months
    
    % Monthly rates
    r = r_annual / 12;
    id = id_annual / 12;
    
    % Harmless shortfall
    q = max(0, g_monthly + s_monthly - c_monthly);
    
    % ODE parameters
    tspan = [0, months];
    y0 = [0; 0; 0]; % Initial gaps: A, W, B
    
    % Run ODE solver
    [~, y] = ode45(@(t, y) gap_dynamics(t, y, q, a, w, b, r, id), tspan, y0);
    
    % Final values
    delta_A = y(end, 1);
    delta_W = y(end, 2);
    delta_B = y(end, 3);
    
    % Total repair deficit
    R = delta_A + delta_W + delta_B + M;
    
    % Recovery Burden Months
    RBM = R / C_rep;
end
