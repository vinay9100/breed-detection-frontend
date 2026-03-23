import json
import os
import time
from deep_translator import GoogleTranslator

with open('extracted_strings.json', 'r') as f:
    strings = json.load(f)

languages = {
    'hi': 'hi',
    'te': 'te',
    'ta': 'ta',
    'kn': 'kn'
}

# Clean and filter strings (remove empty, single chars if needed)
strings = [s for s in strings if len(s.strip()) > 1 and not s.isnumeric()]

# Create EN base strings
with open('BSAI/en.lproj/Localizable.strings', 'w') as f:
    f.write('/* English */\n')
    for s in strings:
        clean_s = s.replace('"', '\\"')
        clean_s = clean_s.replace('\n', '\\n')
        f.write(f'"{clean_s}" = "{clean_s}";\n')

for code, lang_id in languages.items():
    print(f"Translating to {code}...")
    translator = GoogleTranslator(source='en', target=lang_id)
    
    translations = {}
    
    batch_size = 40
    for i in range(0, len(strings), batch_size):
        batch = strings[i:i+batch_size]
        try:
            results = translator.translate_batch(batch)
            for j, s in enumerate(batch):
                translations[s] = results[j]
        except Exception as e:
            print(f"Error on batch: {e}")
            for s in batch:
                try:
                    res = translator.translate(s)
                    translations[s] = res
                except:
                    translations[s] = s
        time.sleep(1)

    with open(f'BSAI/{code}.lproj/Localizable.strings', 'w') as f:
        f.write(f'/* {code} */\n')
        for s in strings:
            clean_s = s.replace('"', '\\"')
            clean_s = clean_s.replace('\n', '\\n')
            t = translations.get(s, s)
            if t is None: t = s
            clean_t = t.replace('"', '\\"')
            clean_t = clean_t.replace('\n', '\\n')
            f.write(f'"{clean_s}" = "{clean_t}";\n')

print("Translation completed.")
