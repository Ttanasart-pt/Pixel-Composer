# %%
import os
import shutil
import re
from tqdm import tqdm
from concurrent.futures import ThreadPoolExecutor

from fileUtil import FileType, pathRemoveOrder, verifyFolder
import genFileWriter

def title(s): # Replace _ with space and capitalize the first letter in each word
    return s.replace('_', ' ').title()
    
# %% Copy image files
nodeIconDir = "datasrc/NodeIcons"
shutil.copytree(nodeIconDir, "docsdata/src/nodeIcons", dirs_exist_ok = True)
shutil.copytree("docsdata/src", "docs/src", dirs_exist_ok = True)

# %%
pages = []
allSidebar = []

def generateFolder(dirIn, dirOut):
    # print(f"Generating {dirIn} -> {dirOut}")
    verifyFolder(dirOut)
    files   = sorted(os.listdir(dirIn))
    sidebar = []

    if dirIn == "docsdata/pregen":
        groupTitle = "Home"
        sidebar.append((FileType.BACK, "", "", ""))
    else:
        groupTitle = os.path.basename(dirIn)
        groupTitle = title(pathRemoveOrder(groupTitle))
        sidebar.append((FileType.BACK, "../", "../", "Back"))
    
    for fName in files:
        if fName.startswith("__"):
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
    
    allSidebar.append((groupTitle, sidebar))

generateFolder("docsdata/pregen", "docs")
shutil.copy("docsdata/styles.css", "docs/styles.css")

# %% generate static search
search_list_str = ""

for title, path in pages:
    if title == "Index":
        continue

    real_path = path.replace("docs\\", "\\")
    search_list_str += f'<li class="search-result" style="display: none;"><a href="{real_path}">{title}</a></li>\n'

# for _, path in tqdm(pages, desc="Static Search"):
#     with open(path, "r") as f:
#         content = f.read()
        
#     content = content.replace("{{search_results}}", search_list_str)
#     with open(path, "w") as f:
#         f.write(content)

def replace_in_file(path, old_text, new_text):
    try:
        with open(path, "r", encoding='utf-8') as f:
            content = f.read()
        
        if old_text in content:
            new_content = content.replace(old_text, new_text)
            with open(path, "w", encoding='utf-8') as f:
                f.write(new_content)
            return f"Updated: {path}"
        else:
            return f"Skipped: {path}"
    except Exception as e:
        return f"Error {path}: {e}"

# Parallel processing
def process_files_parallel(pages, search_list_str, max_workers=None):
    if max_workers is None:
        max_workers = min(32, (os.cpu_count() or 1) + 4)
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [
            executor.submit(replace_in_file, path, "{{search_results}}", search_list_str)
            for _, path in pages
        ]
        
        results = []
        for future in tqdm(futures, desc="Static Search"):
            results.append(future.result())
    
    return results

results = process_files_parallel(pages, search_list_str)