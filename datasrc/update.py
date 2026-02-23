import os
import shutil
import json

root = os.path.dirname(os.path.abspath(__file__))
root = os.path.dirname(root)

lzipPath = f"{root}/datasrc/last_zip.json"
lzipData = json.load(open(lzipPath, 'r')) if os.path.exists(lzipPath) else {}

def packFolder(src, trg, forced = False):    
    srcDir = f"{root}/datasrc/{src}"
    trgZip = f"{root}/datafiles/pack/{trg}"

    lastZipTime  = lzipData.get(src, 0)
    lastEditTime = max(os.path.getmtime(r) if os.path.basename(r) != "last_zip.txt" else 0 for r,_,_ in os.walk(srcDir))

    if lastEditTime <= lastZipTime and not forced:
        print(f" > Skipping {src}, no changes detected.")
        return
    
    print(f" > Packing {src} into {trg}...")
    lzipData[src] = lastEditTime
    
    if(src == "Themes"):
        shutil.copy(f"{srcDir}/default/values.json", f"{srcDir}/default HQ/values.json")
        shutil.copy(f"{srcDir}/default/graphics/graphics.json", f"{srcDir}/default HQ/graphics/graphics.json")

    shutil.make_archive(trgZip, 'zip', srcDir)

if __name__ == "__main__":
    packFolder("Actions", "actions")
    packFolder("Addons", "addons")
    packFolder("Assets", "assets")
    packFolder("Collections", "collections")
    packFolder("Curves", "curves")
    packFolder("Layouts", "layouts")
    packFolder("Locale", "locale")
    packFolder("Nodes", "nodes")
    packFolder("Themes", "themes")
    packFolder("Welcome files", "welcome_files")

    json.dump(lzipData, open(lzipPath, 'w'), indent=4)