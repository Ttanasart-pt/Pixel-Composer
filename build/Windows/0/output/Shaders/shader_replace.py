import os
import re

lib = []
modified = 0

def replace_shader(shader_path):
    with open(shader_path, 'r') as f:
        shader = f.read()
    
    edit = False

    for lName, lCon, lModi in lib:
        reg  = f'\n#region -- {lName} --'
        ereg = f'\n#endregion -- {lName} --\n'

        if f'#pragma use({lName})' not in shader:
            continue

        if reg not in shader:
            shader = f'#pragma use({lName})\n' + reg + f' [{lModi}]\n' + lCon + ereg + re.sub(fr'#pragma use\({lName}\)\n', '', shader)
            edit = True
        else:
            modi = re.search(r'\[(.*)\]', shader.split(reg)[1]).group(0)
            modi = float(modi[1:-1])

            if modi != lModi:
                pre_sh = shader.split(reg)[0]
                post_sh = shader.split(ereg)[1]

                shader = pre_sh + reg + f' [{lModi}]\n' + lCon + ereg + post_sh
                edit = True
    
    if edit:
        with open(shader_path, 'w') as f:
            f.write(shader)

        global modified
        modified += 1

######################################################################################################

gm_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../'))

for l in os.listdir(f'{gm_dir}/datafiles/Shaders'):
    path = f'{gm_dir}/datafiles/Shaders/{l}'
    if not os.path.isfile(path):
        continue
    
    name = l.split('.')[0]
    ext  = l.split('.')[1]
    if ext != 'glsl':
        continue

    with open(path, 'r') as f:
        modi = os.path.getmtime(path)
        lib.append((name, f.read(), modi))

        print(f' > Using library {name} ({modi})')

for sh in os.listdir(f'{gm_dir}/shaders'):
    fsh = f'{gm_dir}/shaders/{sh}/{sh}.fsh'
    replace_shader(fsh)

print(f'\nModified {modified} shaders')