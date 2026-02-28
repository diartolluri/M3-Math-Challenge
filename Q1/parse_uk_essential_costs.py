import pandas as pd
import numpy as np

def parse_uk_essential_costs():
    """
    Parses the UK essential costs from the M3 Challenge dataset.
    Extracts regional spending, applies mathematical transformations (annualize and single-adult baseline),
    and exports a cleaned CSV file.
    """
    
    import os
    
    # 1. Load the Excel file specifically targeting the "Expenditures (U.K.)" sheet
    # Construct path absolute to this script's location
    base_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(base_dir, '..', 'ProblemAndData', 'M3-Challenge-Problem-Data-2026.xlsx')
    
    try:
        df = pd.read_excel(file_path, sheet_name='Expenditures (U.K.)')
    except Exception as e:
        print(f"Error loading the Excel file. Please ensure it is in the correct path. Details: {e}")
        return

    # 2. Programmatically locate the "By region of residence" block
    # We find the first row containing 'by region of residence' ignoring case
    mask = df.map(lambda x: 'by region of residence' in str(x).lower())
    row_idx = mask.any(axis=1).idxmax()
    
    # Slice the dataframe to drop all rows before the "By region of residence" block
    sub_df = df.iloc[row_idx:].reset_index(drop=True)

    # 3. Accurately extract the table columns aligning with the Region names
    # Find the cell containing "England" to anchor our table boundaries
    england_matches = sub_df.where(sub_df.map(lambda x: 'England' == str(x).strip())).stack()
    if england_matches.empty:
        print("Could not find 'England' column.")
        return
        
    header_row_idx, england_col_name = england_matches.index[0]
    england_col_idx = sub_df.columns.get_loc(england_col_name)
    
    # The commodity descriptions are immediately to the left of the "England" column
    item_col_name = sub_df.columns[england_col_idx - 1]
    
    # The regions span exactly 4 columns starting from "England"
    region_cols = list(sub_df.columns[england_col_idx: england_col_idx + 4])
    
    # Extract only these relevant columns
    extracted = sub_df[[item_col_name] + region_cols].copy()
    
    # Rename columns to standardized names for our processing
    extracted.columns = ['Commodity', 'England', 'Wales', 'Scotland', 'Northern Ireland']
    
    # Drop rows where 'Commodity' is missing/NaN
    extracted = extracted.dropna(subset=['Commodity'])

    # Define our target regions
    regions = ['England', 'Wales', 'Scotland', 'Northern Ireland']

    # 4. Define RegEx patterns to match the required categories
    # This matches string variations and footnote references like "Housing(net)¹"
    target_vars = {
        'Base_Housing_Annual': r'housing\s*\(net\)', 
        'Base_Food_Annual': r'food\s*&\s*non-alcoholic drinks',
        'Base_Transport_Annual': r'^transport$',
        'Base_Healthcare_Annual': r'^health$'
    }
    
    # Extract the rows that correspond to our targeted spending categories
    target_rows = {}
    for var, pattern in target_vars.items():
        # Case insensitive Regex matching
        mask_commodity = extracted['Commodity'].astype(str).str.strip().str.contains(pattern, case=False, regex=True)
        matched = extracted[mask_commodity]
        if not matched.empty:
            target_rows[var] = matched.iloc[0]

    # 5. Restructure the data to match the target output schema (melting/pivoting)
    records = []
    for region in regions:
        record = {
            'Country': 'UK',
            'Region': region,
        }
        for var in target_vars.keys():
            # Extract the raw weekly numeric value for the specific commodity and region
            val = target_rows[var][region] if var in target_rows else pd.NA
            record[var] = val
        records.append(record)

    final_df = pd.DataFrame(records)

    # Provide the exact final column ordering
    target_columns_order = [
        'Country', 
        'Region', 
        'Base_Housing_Annual', 
        'Base_Food_Annual', 
        'Base_Transport_Annual', 
        'Base_Healthcare_Annual'
    ]
    
    final_df = final_df[target_columns_order]

    # 6. Apply Mathematical Transformations
    # Formula: Final_Value = Raw_Value * 52 * 0.5
    # (Raw_Value * 52) annualizes the value
    # (* 0.5) scales down to approx. 1-adult household essentials
    numeric_cols = [c for c in target_columns_order if c.startswith('Base_')]
    for col in numeric_cols:
        final_df[col] = pd.to_numeric(final_df[col], errors='coerce') * 52 * 0.5

    # Save output to CSV without pandas index
    # Resolve the path to ensure it always saves centrally or inside Q1 relative to where it ran.
    # We will just write it relative to wherever it is executed, but let's place it exactly 
    # where the script is if desired, or let's use absolute path relative to the script:
    output_path = os.path.join(base_dir, 'uk_essential_costs.csv')
    final_df.to_csv(output_path, index=False)
    print(f"Exported '{output_path}' successfully.")

if __name__ == "__main__":
    parse_uk_essential_costs()
