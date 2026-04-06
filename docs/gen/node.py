# %%
import os
import fileUtil
import json5 as json
from tqdm import tqdm

import nodeWriter

VERSION = "<v 1.19.0/>"

# %% Read node metadata
nodeDir  = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datafiles/data/Nodes/Internal"
nodeList = []
for root, dirs, files in os.walk(nodeDir):
    for file in files:
        if file.endswith(".json"):
            nodeList.append(os.path.join(root, file))

# %% Load node metadata
def getNodeMetadata(nodePath):
    with open(nodePath, 'r') as f:
        nodeData = json.load(f)
    return nodeData

# %% Generate contents
nodeContent  = {}
nodeMetadata = {}

for nodePath in tqdm(nodeList, desc="Generating node content"):
    nodeMeta = getNodeMetadata(nodePath)
    if not nodeMeta:
        print(f"Node data for {nodePath} not found.")
        continue
    
    nodeBase = nodeMeta["baseNode"]
    nodeName = nodeMeta["name"]
    
    contentPath = f"../content/__nodes/{fileUtil.pathSanitize(nodeName)}.html"
    fileUtil.verifyFile(contentPath)

    content = nodeWriter.writeNode(nodeMeta, contentPath)
    if not content:
        print(f"Cannot write content for {nodeBase}.")
        continue

    nodeContent[nodeBase]  = content
    nodeMetadata[nodeBase] = nodeMeta
    
# %% Write content to file using category
targetRoot = "../pregen/3_nodes"
fileUtil.verifyFile("../docs/nodes/_index/index.html", f'''<!DOCTYPE html><html></html>''')
fileUtil.verifyFolder(targetRoot)

nodeCategoryDir = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datafiles/data/Nodes/display_data.json"
with open(nodeCategoryDir, 'r') as f:
    nodeCategoryData = json.load(f)

nodeCategory = {}
for category in nodeCategoryData:
    cName  = category["name"]
    cNodes = category["nodes"]
    if not cNodes:
        continue

    nodeCategory[cName] = cNodes
    
    categoryDir = os.path.join(targetRoot, fileUtil.pathSanitize(cName))
    fileUtil.verifyFolder(categoryDir)

    categoryContent  = f'''<!DOCTYPE html><html></html>{VERSION}'''
    categoryContent += nodeWriter.writeCategory(category, nodeMetadata)
    fileUtil.writeFile(f"{categoryDir}/index.html", categoryContent)

    for node in cNodes:
        if not isinstance(node, str):
            continue

        if node not in nodeContent:
            print(f"Node content for {node} not found.")
            continue
        
        fname = fileUtil.pathSanitize(node)
        fname = fname.replace("node_", "")

        targetPath = os.path.join(categoryDir, fname + ".html")
        fileUtil.writeFile(targetPath, nodeContent[node])

        nodeMeta = nodeMetadata[node]
        nodeName = nodeMeta["name"]
        nodeName = fileUtil.pathSanitize(nodeName)

        redirectPath = f"../docs/nodes/_index/{nodeName}.html"
        with open(redirectPath, "w") as file:
            file.write(f'''<!DOCTYPE html><html><meta http-equiv="refresh" content="0; url=/nodes/{cName.lower()}/{nodeName}.html"/></html>''')

    