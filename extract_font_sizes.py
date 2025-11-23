import os
import re
import csv

def parse_clamp(value):
    """
    Parses a clamp() value and returns (min, val, max).
    Returns (None, None, None) if not a clamp value.
    """
    if not value.strip().lower().startswith('clamp('):
        return None, None, None
    
    match = re.search(r'clamp\((.*)\)', value, re.IGNORECASE)
    if match:
        content = match.group(1)
        parts = [p.strip() for p in content.split(',')]
        if len(parts) == 3:
            return parts[0], parts[1], parts[2]
    return None, None, None

def extract_variable_from_value(value):
    """
    Extracts the first variable name found in a value.
    """
    match = re.search(r'var\((--[\w-]+)', value)
    if match:
        return match.group(1)
    return ''

def parse_css_file(file_path):
    """
    Parses a CSS file and returns a list of raw entries:
    {'selector': ..., 'media': ..., 'prop': ..., 'value': ...}
    """
    entries = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Remove comments
        content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
        
        stack = [] 
        tokens = re.finditer(r'([{}])', content)
        last_pos = 0
        
        for token in tokens:
            char = token.group(1)
            pos = token.start()
            
            if char == '{':
                preceding_text = content[last_pos:pos].strip()
                if preceding_text.lower().startswith('@media'):
                    query = preceding_text[6:].strip() 
                    stack.append(('media', query))
                else:
                    selector = preceding_text
                    media_context = "Default"
                    for item in reversed(stack):
                        if item[0] == 'media':
                            media_context = item[1]
                            break
                    stack.append(('rule', selector, media_context, pos + 1))
            
            elif char == '}':
                if stack:
                    top = stack.pop()
                    if top[0] == 'rule':
                        _, selector, media_context, start_content = top
                        rule_body = content[start_content:pos]
                        
                        # Capture all properties
                        matches = re.finditer(r'([\w-]+)\s*:\s*([^;]+);', rule_body, re.IGNORECASE)
                        for match in matches:
                            prop = match.group(1).strip()
                            value = match.group(2).strip()
                            entries.append({
                                'selector': re.sub(r'\s+', ' ', selector).strip(),
                                'media': media_context,
                                'prop': prop,
                                'value': value
                            })
            last_pos = token.end()
            
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        
    return entries

def extract_inline_styles(root_dir):
    results = []
    exclude_dirs = {'_site', '.git', '.jekyll-cache'}
    
    for root, dirs, files in os.walk(root_dir):
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        
        for file in files:
            if file.endswith(('.html', '.md')):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        lines = f.readlines()
                        
                    for line_num, line in enumerate(lines, 1):
                        if 'font-size' in line and 'style=' in line:
                            match = re.search(r'style="[^"]*font-size\s*:\s*([^;"]+)', line, re.IGNORECASE)
                            if match:
                                size = match.group(1).strip()
                                rel_path = os.path.relpath(file_path, root_dir)
                                results.append({
                                    'file': rel_path,
                                    'selector': f"Line {line_num}",
                                    'media': 'Inline',
                                    'prop': 'font-size',
                                    'value': size
                                })
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
    return results

def main():
    root_dir = os.path.dirname(os.path.abspath(__file__))
    print(f"Working in: {root_dir}")
    
    # 1. Collect all data
    all_css_entries = []
    css_path = os.path.join(root_dir, 'assets', 'css', 'style.css')
    if os.path.exists(css_path):
        print("Parsing CSS file...")
        all_css_entries = parse_css_file(css_path)
    
    print("Parsing inline styles...")
    inline_entries = extract_inline_styles(root_dir)
    
    # 2. Build variable map from :root (Default) to resolve values
    var_map = {}
    for entry in all_css_entries:
        if entry['selector'] == ':root' and entry['media'] == 'Default' and entry['prop'].startswith('--'):
            var_map[entry['prop']] = entry['value']

    # 3. Build final dataset
    final_data = []
    
    # Helper to process an entry
    def process_entry(entry, entry_type, file_name):
        raw_value = entry['value']
        var_name = ''
        
        # If it's a variable definition
        if entry['prop'].startswith('--'):
            var_name = entry['prop']
            display_value = raw_value
        else:
            # It's a font-size property
            var_name = extract_variable_from_value(raw_value)
            if var_name and var_name in var_map:
                display_value = var_map[var_name]
            else:
                display_value = raw_value
        
        clamp_min, clamp_val, clamp_max = parse_clamp(display_value)
        
        return {
            'Type': entry_type,
            'File': file_name,
            'Selector': entry['selector'],
            'Media Query': entry['media'],
            'Variable Name': var_name,
            'Value': display_value,
            'Clamp Min': clamp_min if clamp_min else '',
            'Clamp Val': clamp_val if clamp_val else '',
            'Clamp Max': clamp_max if clamp_max else ''
        }

    # Add all font-size usages from CSS
    for entry in all_css_entries:
        if entry['prop'] == 'font-size':
            final_data.append(process_entry(entry, 'CSS File', 'style.css'))

    # Add all inline styles
    for entry in inline_entries:
        # Inline entries structure is slightly different in my previous code, let's adapt
        # entry: {'file': ..., 'selector': ..., 'media': ..., 'prop': ..., 'value': ...}
        final_data.append(process_entry(entry, 'Inline Style', entry['file']))

    # Add relevant variable definitions
    # We want variables that are used in font-size or look like font sizes
    
    # Re-identify relevant vars based on usage in final_data
    used_vars = set()
    for item in final_data:
        if item['Variable Name']:
            used_vars.add(item['Variable Name'])
            
    for entry in all_css_entries:
        if entry['prop'].startswith('--'):
            # Include if used OR if it looks like a font variable
            is_relevant = (entry['prop'] in used_vars) or \
                          ('font-size' in entry['prop']) or \
                          ('fs-' in entry['prop']) or \
                          ('clamp' in entry['value'])
            
            if is_relevant:
                final_data.append(process_entry(entry, 'CSS Variable', 'style.css'))

    # Sort
    final_data.sort(key=lambda x: (x['Type'], x['Selector'], x['Media Query']))
    
    output_file = os.path.join(root_dir, 'font_sizes_report.csv')
    
    if final_data:
        keys = ['Type', 'File', 'Selector', 'Media Query', 'Variable Name', 'Value', 'Clamp Min', 'Clamp Val', 'Clamp Max']
        with open(output_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=keys)
            writer.writeheader()
            writer.writerows(final_data)
        print(f"Successfully created {output_file} with {len(final_data)} entries.")
    else:
        print("No data found.")

if __name__ == "__main__":
    main()

if __name__ == "__main__":
    main()
