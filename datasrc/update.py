import os
import shutil
import json
import re

root = os.path.dirname(os.path.abspath(__file__))
root = os.path.dirname(root)

lzipPath = f"{root}/datasrc/last_zip.json"
lzipData = json.load(open(lzipPath, 'r')) if os.path.exists(lzipPath) else {}

version    = None
globalPath = f"{root}/scripts/globals/globals.gml"
with open(globalPath, 'r') as f:
    globalContent = f.read()
    versionMatch = re.search(r'\sVERSION\s*=\s*([^\"]+?);', globalContent, re.MULTILINE)
    if versionMatch:
        versionStr = versionMatch.group(1)
        versionStr = versionStr.replace(' ', '').replace("_", "")
        version = int(versionStr)

def updateThemeMeta(theme):
    if version is None:
        return
    
    thmDir = f"{root}/datasrc/Themes/{theme}"
    metaP  = f"{thmDir}/meta.json"
    if not os.path.exists(metaP):
        return
    
    jsonData = json.load(open(metaP, 'r'))
    if jsonData.get('version') == version:
        return;
    
    jsonData['version'] = version
    json.dump(jsonData, open(metaP, 'w'), indent=4)

def packFolder(src, trg, forced = False):    
    srcDir = f"{root}/datasrc/{src}"
    trgZip = f"{root}/datafiles/pack/{trg}"

    lastZipTime  = lzipData.get(src, 0)
    lastEditTime = max(os.path.getmtime(r) if os.path.basename(r) != "last_zip.txt" else 0 for r,_,_ in os.walk(srcDir))

    if lastEditTime <= lastZipTime and not forced:
        print(f" x Skipping {src}, no changes detected.")
        return
    
    print(f" > Packing {src} into {trg}...")
    lzipData[src] = lastEditTime
    
    if(src == "Themes"):
        shutil.copy(f"{srcDir}/default/values.json", f"{srcDir}/default HQ/values.json")
        shutil.copy(f"{srcDir}/default/graphics/graphics.json", f"{srcDir}/default HQ/graphics/graphics.json")

    shutil.make_archive(trgZip, 'zip', srcDir)

def packNodeIcons():
    srcDir = f"{root}/datasrc/NodeIcons"
    trgZip = f"{root}/datafiles/pack/node_icons"

    lastZipTime  = lzipData.get("Node icons", 0)
    lastEditTime = max(os.path.getmtime(r) if os.path.basename(r) != "last_zip.txt" else 0 for r,_,_ in os.walk(srcDir))

    if lastEditTime <= lastZipTime:
        print(f" x Skipping NodeIcons, no changes detected.")
        return
    
    print(f" > Packing NodeIcons into node_icons...")
    lzipData["Node icons"] = lastEditTime

    tmpDir = f"{root}/datasrc/__NodeIcons"
    if os.path.exists(tmpDir):
        shutil.rmtree(tmpDir)

    # copy only .png from src to tmpDir
    os.makedirs(tmpDir, exist_ok=True)
    for item in os.listdir(srcDir):
        if item.endswith('.png'):
            shutil.copy(os.path.join(srcDir, item), os.path.join(tmpDir, item))
    
    shutil.make_archive(trgZip, 'zip', tmpDir)
    shutil.rmtree(tmpDir)

if __name__ == "__main__":
    print(f"Updating data files for version {version}...")
    updateThemeMeta("default")
    updateThemeMeta("default HQ")
    updateThemeMeta("True Dark")

    packFolder("Actions", "actions")
    packFolder("Addons", "addons")
    packFolder("Assets", "assets")
    packFolder("Curves", "curves")
    packFolder("Layouts", "layouts")
    packFolder("Locale", "locale")
    packFolder("Nodes", "nodes")
    packFolder("Themes", "themes")
    packFolder("Welcome files", "welcome_files")
    packNodeIcons()
    json.dump(lzipData, open(lzipPath, 'w'), indent=4)