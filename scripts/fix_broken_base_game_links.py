import os
import shutil

base = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'assets', 'base_game'))
backup_root = os.path.abspath(os.path.join(os.path.dirname(__file__), 'broken_links_backup'))

print 'Base dir:', base
print 'Backup root:', backup_root

if not os.path.isdir(base):
    print 'Base directory missing:', base
    raise SystemExit(1)

os.makedirs(backup_root, exist_ok=True)

moved = []
errors = []

for name in os.listdir(base):
    child = os.path.join(base, name)

    # Only consider entries that currently appear as directories or reparse points
    if not os.path.exists(child):
        errors.append((name, 'does not exist'))
        continue

    # Try listing the directory; catch the WinError 3 or similar failures
    if os.path.isdir(child):
        try:
            os.listdir(child)
            # listed OK
        except Exception as e:
            # Treat this as a broken junction/link; move it to backup
            dest = os.path.join(backup_root, name)
            try:
                # Use shutil.move which works for files, dirs, and junctions
                shutil.move(child, dest)
                moved.append((name, dest))
                print 'Moved broken entry:', child, '->', dest
            except Exception as e2:
                errors.append((name, 'move failed: ' + str(e2)))
    else:
        # Not a dir (file). skip
        continue

print '\nSummary:'
print 'Moved:', len(moved)
for m in moved:
    print ' -', m[0], '->', m[1]

if errors:
    print '\nErrors:'
    for e in errors:
        print ' -', e[0], e[1]
else:
    print 'No errors.'
