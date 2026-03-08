import os
import re
import json

strings = set()
for root, dirs, files in os.walk('BSAI'):
    for f in files:
        if f.endswith('.swift'):
            with open(os.path.join(root, f), 'r') as file:
                content = file.read()
                matches = re.findall(r'(?:Text|Label|String)\(\"([^\"]+)\"\)', content)
                for match in matches:
                    strings.add(match)

print(f"Total unique strings: {len(strings)}")
with open('extracted_strings.json', 'w') as f:
    json.dump(list(strings), f, indent=4)
