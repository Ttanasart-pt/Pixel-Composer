# %%
import os
import shutil
import re
from tqdm import tqdm
from concurrent.futures import ThreadPoolExecutor

import fileUtil
from fileUtil import FileType, pathRemoveOrder, verifyFolder
import genFileWriter

def title(s): # Replace _ with space and capitalize the first letter in each word
    return s.replace('_', ' ').title()
    
# %% Copy image files
nodeIconDir = "datasrc/NodeIcons"
shutil.copytree(nodeIconDir, "docsdata/src/nodeIcons", dirs_exist_ok = True)
shutil.copytree("docsdata/src", "docs/src", dirs_exist_ok = True)

svg_home = fileUtil.readFile("docs/src/svg/home.svg")
svg_dir  = fileUtil.readFile("docs/src/svg/dir.svg")

# %%
pages = []
allSidebar = []

def generateFolder(dirIn, dirOut, sidebarParent = allSidebar):
    # print(f"Generating {dirIn} -> {dirOut}")
    verifyFolder(dirOut)
    files   = sorted(os.listdir(dirIn))
    sidebar = []
    groupTitle = title(os.path.basename(dirOut))

    for fName in files:
        if fName.startswith("__"):
            continue
        
        fullPath = os.path.join(dirIn, fName)
        fNameS   = pathRemoveOrder(fName)
        if fullPath.endswith(".md"):
            continue   

        fDirIn  = os.path.join(dirIn,  fName)
        fDirOut = os.path.join(dirOut, fNameS)
        
        if os.path.isdir(fullPath):
            pTitle = title(fNameS)
            generateFolder(fDirIn, fDirOut)
            continue

        if not fullPath.endswith(".html"):
            shutil.copy(fullPath, fDirOut)
            continue

        if fName == "index.html":
            pTitle = groupTitle
        else:
            pTitle = title(fNameS.replace('.html', ''))

        page = genFileWriter.generateFile(dirOut, fDirIn)
        pages.append(page)
        sidebar.append((fName, fNameS, pTitle))
    
    sidebarParent.append((groupTitle, sidebar))

generateFolder("docsdata/pregen", "docs")
shutil.copy("docsdata/styles.css", "docs/styles.css")

# %% generate sidebar

def writeSidebar(sidebar):
    if len(sidebar) == 0:
        return ""
    
    if len(sidebar) == 2:
        title, contents = sidebar
        sideContent = f'''<ul><li><a href="/" class="sidebar-dir">{title}</a>\n'''
        for content in contents:
            sideContent += writeSidebar(content)
        sideContent += "</li></ul>\n"

    if len(sidebar) == 3:
        fName, fNameS, title = sidebar
        sideContent = f'''<li><a href="{fName}" class="sidebar-file">{title}</a></li>\n'''

    return sideContent

sidebarContent = '<ul class="sidebar-content">\n'
for s in allSidebar:
    sidebarContent += writeSidebar(s)
sidebarContent += '</ul>\n'

# %% generate static search
search_list_str = ""

for title, path in pages:
    if title == "Index":
        continue

    real_path = path.replace("docs\\", "\\")
    search_list_str += f'<li class="search-result" style="display: none;"><a href="{real_path}">{title}</a></li>\n'

# %% multithreaded replace in file
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

def process_files_parallel(pages, replace_key, replace_value, tqdm_desc="Static Search", max_workers=None):
    if max_workers is None:
        max_workers = min(32, (os.cpu_count() or 1) + 4)
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [
            executor.submit(replace_in_file, path, replace_key, replace_value)
            for _, path in pages
        ]
        
        results = []
        for future in tqdm(futures, desc=tqdm_desc):
            results.append(future.result())
    
    return results

process_files_parallel(pages, "{{sidebar}}", sidebarContent, tqdm_desc="Sidebar")
process_files_parallel(pages, "{{search_results}}", search_list_str, tqdm_desc="Static Search")