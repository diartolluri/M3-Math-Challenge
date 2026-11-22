import os

# The ordered list of files to concatenate
files_to_include = [
    'Q1/apply_oecd_scale.m',
    'Q1/calculate_essentials.m',
    'Q1/calculate_taxes.m',
    'Q1/simulate_monthly_shocks.m',
    'Q1/main_Q1_monthly.m',
    'Q1/run_sensitivity_analysis.m',
    'Q1_Visualization_Pipeline.m'
]

output_filename = "Q1_Combined_Code.m"

with open(output_filename, 'w', encoding='utf-8') as f_out:
    f_out.write("%% Q1 Project Codebase\n\n")

    for file_path in files_to_include:
        if os.path.exists(file_path):
            print(f"Adding {file_path}...")
            f_out.write(f"%% {'='*60}\n")
            f_out.write(f"%% FILE: {os.path.basename(file_path)}\n")
            f_out.write(f"%% {'='*60}\n\n")
            
            with open(file_path, 'r', encoding='utf-8') as f_in:
                code = f_in.read()
            f_out.write(code)
            f_out.write("\n\n")
        else:
            print(f"Warning: Could not find {file_path}")

print("\n--- Success! ---")
print(f"Created file: {os.path.abspath(output_filename)}")
print("\nInstructions for copying:")
print(f"1. Open the created {output_filename} right here in VS Code.")
print("2. Press Cmd+A to select all, then Cmd+C to copy.")
print("3. Paste directly into your Word document.")
