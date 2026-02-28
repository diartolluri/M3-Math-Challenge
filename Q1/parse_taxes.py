import pandas as pd
import re
import math

df = pd.read_excel('Q1/2026-State-Individual-Income-Tax-Rates-Brackets.xlsx')

rates_dict = {}
current_state = None

for i, row in df.iterrows():
    state_cell = str(row.iloc[0]).strip()
    rate_cell = str(row.iloc[1]).strip()
    
    if state_cell and state_cell != 'nan' and not state_cell.startswith('('):
        # clean state name
        current_state = re.sub(r'\(.*?\)', '', state_cell).strip().strip('.')
        if current_state == 'State' or current_state == 'D.C':
            if current_state == 'State': current_state = None
            if current_state == 'D.C': current_state = 'District of Columbia'
            
    if current_state:
        if rate_cell and rate_cell != 'nan':
            # keep all rates for the state
            if current_state not in rates_dict:
                rates_dict[current_state] = []
            
            # Handle 'none' or 'Capital gains income only'
            if rate_cell.lower() == 'none' or 'capital gains' in rate_cell.lower():
                rates_dict[current_state].append(0.0)
            else:
                try:
                    val = float(rate_cell)
                    rates_dict[current_state].append(val)
                except ValueError:
                    # try to extract a number if it's text
                    nums = re.findall(r'\d+\.?\d*', rate_cell)
                    if nums:
                        rates_dict[current_state].append(float(nums[0]))
                    else:
                        rates_dict[current_state].append(0.0)

final_data = []

state_map = {
    'Ala': 'Alabama', 'Alaska': 'Alaska', 'Ariz': 'Arizona', 'Ark': 'Arkansas',
    'Calif': 'California', 'Colo': 'Colorado', 'Conn': 'Connecticut', 'Del': 'Delaware',
    'Fla': 'Florida', 'Ga': 'Georgia', 'Hawaii': 'Hawaii', 'Idaho': 'Idaho',
    'Ill': 'Illinois', 'Ind': 'Indiana', 'Iowa': 'Iowa', 'Kans': 'Kansas',
    'Ky': 'Kentucky', 'La': 'Louisiana', 'Maine': 'Maine', 'Md': 'Maryland',
    'Mass': 'Massachusetts', 'Mich': 'Michigan', 'Minn': 'Minnesota', 'Miss': 'Mississippi',
    'Mo': 'Missouri', 'Mont': 'Montana', 'Nebr': 'Nebraska', 'Nev': 'Nevada',
    'N.H': 'New Hampshire', 'N.J': 'New Jersey', 'N.M': 'New Mexico', 'N.Y': 'New York',
    'N.C': 'North Carolina', 'N.D': 'North Dakota', 'Ohio': 'Ohio', 'Okla': 'Oklahoma',
    'Ore': 'Oregon', 'Pa': 'Pennsylvania', 'R.I': 'Rhode Island', 'S.C': 'South Carolina',
    'S.D': 'South Dakota', 'Tenn': 'Tennessee', 'Tex': 'Texas', 'Utah': 'Utah',
    'Vt': 'Vermont', 'Va': 'Virginia', 'Wash': 'Washington', 'W.Va': 'West Virginia',
    'Wis': 'Wisconsin', 'Wyo': 'Wyoming', 'District of Columbia': 'District of Columbia'
}

for raw_state, rates in rates_dict.items():
    if not rates:
        continue
    
    # Calculate effective rate (max rate as requested if there are multiple)
    max_rate = max(rates)
    
    # Format to strictly a decimal. 
    # Usually in this sheet they are already 0.04 etc., so we just keep it.
    if max_rate > 1.0:
        max_rate = max_rate / 100.0
    
    # Get full state name
    state_name = state_map.get(raw_state, raw_state)
    
    final_data.append({
        'Country': 'US',
        'Region': state_name,
        'Effective_State_Tax_Rate': round(max_rate, 5)
    })

# Append UK data
uk_regions = ['England', 'Scotland', 'Wales']
for region in uk_regions:
    final_data.append({
        'Country': 'UK',
        'Region': region,
        'Effective_State_Tax_Rate': 0.00
    })

df_final = pd.DataFrame(final_data)
df_final.to_csv('tax_rates.csv', index=False, float_format='%.4f')
print("Output generated in 'tax_rates.csv'")
