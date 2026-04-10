import os
p = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'assets', 'base_game'))
print('Base:',p)
for name in os.listdir(p):
    full=os.path.join(p,name)
    print(name, 'isdir=', os.path.isdir(full), 'isfile=', os.path.isfile(full), 'islink=', os.path.islink(full), 'exists=', os.path.exists(full))
