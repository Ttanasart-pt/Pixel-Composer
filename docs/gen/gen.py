# %%
import os
import shutil
import re

from fileUtil import FileType, pathRemoveOrder, verifyFolder
import genFileWriter

def title(s): # Replace _ with space and capitalize the first letter in each word
    return s.replace('_', ' ').title()
    
# %% Copy image files
nodeIconDir = "D:/Project/MakhamDev/LTS-PixelComposer/RESOURCE/nodeIcons"
shutil.copytree(nodeIconDir, "../src/nodeIcons", dirs_exist_ok = True)
shutil.copytree("../src", "../docs/src", dirs_exist_ok = True)

# %%
pages = []

def generateFolder(dirIn, dirOut):
    # print(f"Generating {dirIn} -> {dirOut}")
    verifyFolder(dirOut)
    files   = sorted(os.listdir(dirIn))
    sidebar = []

    if dirIn == "../pregen":
        groupTitle = "Home"
        sidebar.append((FileType.BACK, "", "", ""))
    else:
        groupTitle = os.path.basename(dirIn)
        groupTitle = title(pathRemoveOrder(groupTitle))
        sidebar.append((FileType.BACK, "../", "../", "Back"))
    
    for fName in files:
        if fName.startswith("_"):
            continue
        
        fullPath = os.path.join(dirIn, fName)
        fNameS   = pathRemoveOrder(fName)
        
        if os.path.isdir(fullPath):
            pTitle = title(fNameS)
            sidebar.append((FileType.DIR, fName, fNameS, pTitle))

        elif fName == "index.html":
            pTitle = groupTitle
            sidebar.insert(1, (FileType.FILE, fName, fNameS, pTitle))

        elif fullPath.endswith(".html"):
            pTitle = title(fNameS.replace('.html', ''))
            sidebar.append((FileType.FILE, fName, fNameS, pTitle))

        elif fullPath.endswith(".md"):
            continue   
        
        else :
            shutil.copy(fullPath, os.path.join(dirOut, fName))

    for fType, fName, fNameS, _ in sidebar[1:]:
        fDirIn  = os.path.join(dirIn,  fName)
        fDirOut = os.path.join(dirOut, fNameS)

        if fType == FileType.DIR:
            generateFolder(fDirIn, fDirOut)

        elif fType == FileType.FILE:
            page = genFileWriter.generateFile(dirOut, fDirIn, sidebar)
            pages.append(page)

generateFolder("../pregen", "../docs")
shutil.copy("../styles.css", "../docs/styles.css")

# %% generate static search
search_list_str = ""
for title, path in pages:
    if title == "Index":
        continue

    real_path = path.replace("../docs\\", "\\")
    search_list_str += f'<li class="search-result" style="display: none;"><a href="{real_path}">{title}</a></li>\n'

for _, path in pages:
    with open(path, "r") as f:
        content = f.read()
    content  = content.replace("{{search_results}}", search_list_str)
    with open(path, "w") as f:
        f.write(content)