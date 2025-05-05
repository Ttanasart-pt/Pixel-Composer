# %% 
import os
import re

srcDir = "D:\\Project\\MakhamDev\\LTS-PixelComposer\\EXE"
trgDir = "D:\\Project\\MakhamDev\\LTS-PixelComposer\\PixelComposer\\releases"

notes = []

for path, dirList, fileList in os.walk(srcDir):
    for fileName in fileList:
        if fileName == "Release note.md":
            filePath = os.path.join(path, fileName)
            notes.append(filePath)

print(f"Release notes found:{notes}")
# %%
def isVersionName(name):
    # check if name only contains digits and dots
    if re.match(r'^[0-9.]+$', name):
        return True
    return False

def getVersionName(path):
    _dir = path
    patch = None

    while _dir != "":
        _dir = os.path.dirname(_dir)
        bname = os.path.basename(_dir)

        if "patch" in bname.lower() or bname.startswith("p"):
            patch = re.sub(r'[^0-9]', '', bname)
            if patch == "":
                patch = None
            continue

        if isVersionName(bname):
            if patch is not None:
                bname = f"{bname}.{patch}"
            return bname
        
    return None

print("\n==== Updating release notes... ====\n")

for note in notes:
    v = getVersionName(note)
    if v is None:
        print(f"Version name not found in path: {note}")
        continue

    print(f"{v}: {note}")

    trgFile = os.path.join(trgDir, f"{v}.md")
    
    with open(note, "r", encoding="utf-8") as src:
        content = src.read()
    
    with open(trgFile, "w", encoding="utf-8") as trg:
        trg.write(content)
# %%
