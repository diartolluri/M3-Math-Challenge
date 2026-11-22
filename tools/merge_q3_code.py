import os
import sys
import subprocess

def ensure_pygments():
    try:
        import pygments
        import pygments.lexers
        import pygments.formatters
    except ImportError:
        print("Pygments not found. Installing now to generate syntax highlighting...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pygments"])
        import pygments
        import pygments.lexers
        import pygments.formatters
    return pygments

pygments = ensure_pygments()
from pygments import highlight
from pygments.lexers import get_lexer_by_name
from pygments.formatters import HtmlFormatter

# The ordered list of files to concatenate for Q3
files_to_include = [
    'Q3/gap_dynamics.m',
    'Q3/calculate_RBM.m',
    'Q3/MAIN_Q3.m',
    'Q3/sensitivity_analysis_Q3.m'
]

formatter = HtmlFormatter(style='vs', noclasses=True, wrapcode=True)
lexer = get_lexer_by_name('matlab')

html_content = "<html><body style='font-family: Consolas, monospace;'>"
html_content += "<h1 style='font-family: sans-serif;'>Q3 Project Codebase</h1>"

for file_path in files_to_include:
    if os.path.exists(file_path):
        print(f"Adding {file_path}...")
        with open(file_path, 'r', encoding='utf-8') as f:
            code = f.read()
        
        html_content += f"<h2 style='font-family: sans-serif; margin-top: 30px; padding: 5px; background-color: #f0f0f0;'>{os.path.basename(file_path)}</h2>"
        html_content += highlight(code, lexer, formatter)
    else:
        print(f"Warning: Could not find {file_path}")

html_content += "</body></html>"

output_filename = "Q3_Combined_Code.html"
with open(output_filename, 'w', encoding='utf-8') as f:
    f.write(html_content)

print("\n--- Success! ---")
print(f"Created file: {os.path.abspath(output_filename)}")
print("\nInstructions for copying into Microsoft Word:")
print("1. Locate Q3_Combined_Code.html in your folder.")
print("2. Double-click it to open in any web browser (Chrome, Safari, Edge).")
print("3. Press Cmd+A to select all, then Cmd+C to copy.")
print("4. Paste directly into your Word document.")
print("The syntax highlighting will be completely preserved!")
