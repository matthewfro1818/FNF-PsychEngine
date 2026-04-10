import os
import xml.etree.ElementTree as ET

project = os.path.join(os.path.dirname(__file__), '..', 'Project.xml')
project = os.path.abspath(project)

print('Project file:', project)

tree = ET.parse(project)
root = tree.getroot()

errors = []

for assets in root.findall('.//assets'):
    path_attr = assets.get('path')
    if path_attr is None:
        continue
    resolved = os.path.normpath(os.path.join(os.path.dirname(project), path_attr))
    exists = os.path.exists(resolved)
    isdir = os.path.isdir(resolved)
    print(f"assets path='{path_attr}' -> '{resolved}' exists={exists} isdir={isdir}")
    if not exists:
        errors.append((path_attr, resolved, 'missing'))
    elif isdir:
        try:
            items = os.listdir(resolved)
            print(f"  listdir OK, {len(items)} entries")
        except Exception as e:
            errors.append((path_attr, resolved, f'listdir error: {e}'))

        # Recursively attempt to list every subdirectory to catch problematic entries
        for dirpath, dirnames, filenames in os.walk(resolved):
            for d in dirnames:
                sub = os.path.join(dirpath, d)
                try:
                    _ = os.listdir(sub)
                except Exception as e:
                    errors.append((path_attr, sub, f'recursive listdir error: {e}'))

print('\nSummary:')
if errors:
    for e in errors:
        print('ERROR:', e)
else:
    print('No missing assets paths or listdir errors found.')
