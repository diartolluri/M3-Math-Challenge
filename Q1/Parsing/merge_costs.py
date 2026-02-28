import pandas as pd
import os

# Define file paths
base_dir = os.path.dirname(os.path.abspath(__file__))
us_path = os.path.join(base_dir, 'essential_costs_us.csv')
uk_path = os.path.join(base_dir, 'uk_essential_costs.csv')
output_path = os.path.join(base_dir, 'essential_costs.csv')

# Load the dataframes
us_df = pd.read_csv(us_path)
uk_df = pd.read_csv(uk_path)

# Ensure Healthcare values for UK are set to 250 explicitly per requested output
uk_df['Base_Healthcare_Annual'] = 250

# Map US regions to just the state name, based on the requested output
us_region_mapping = {
    "Harris County, TX": "Texas",
    "Los Angeles County, CA": "California",
    "New York County, NY": "New York",
    "Miami-Dade County, FL": "Florida"
}
us_df['Region'] = us_df['Region'].map(us_region_mapping).fillna(us_df['Region'])

# Combine the dataframes
merged_df = pd.concat([us_df, uk_df], ignore_index=True)

# Round the values to integers as shown in the requested output
numeric_cols = ['Base_Housing_Annual', 'Base_Food_Annual', 'Base_Transport_Annual', 'Base_Healthcare_Annual']
for col in numeric_cols:
    merged_df[col] = merged_df[col].round().astype(int)

# Reorder columns just to be safe
merged_df = merged_df[['Country', 'Region', 'Base_Housing_Annual', 'Base_Food_Annual', 'Base_Transport_Annual', 'Base_Healthcare_Annual']]

# Save to the new master CSV
merged_df.to_csv(output_path, index=False)
print(f"Master CSV successfully saved to {output_path}")
