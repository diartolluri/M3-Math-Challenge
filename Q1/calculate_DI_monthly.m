function months_dI = calculate_DI_monthly(persona)
        annual_net_income = calculate_taxes(persona);
        
        % Module B: Estimate baseline single-adult essential costs (Annual)
        annual_base_essentials = calculate_essentials(persona, cost_data);
        
        % Module C: Convert baseline single-adult costs to individual's share of household costs (Annual)
        annual_indiv_essentials = apply_oecd_scale(annual_base_essentials, persona.Adults, persona.Children);
        
        % Convert Annual to Monthly
        monthly_net_income = annual_net_income / 12;
        monthly_indiv_essentials = annual_indiv_essentials / 12;
        
        % Module D: Final Calculation Monthly Id
        monthly_Id = max(monthly_net_income - monthly_indiv_essentials, 0);
        
        % Array of disposable income over 12 months (Fixed over time)
        months_dI = repmat(monthly_Id, 1, 12);
end