# %%
import os
import re
import fileUtil
import json5 as json
from tqdm import tqdm

import nodeWriter

# %% Get Version number
version_path = "scripts/globals/globals.gml"
with open(version_path, 'r') as f:
    version_data = f.read()
version_string = re.search(r'VERSION_STRING\s*=\s*\"([^\"]+)\"', version_data)

version_tag = "undef"
if version_string:
    version_tag = version_string.group(1)
VERSION = f"<v {version_tag}/>"

# %% Read node metadata
nodeDir  = "datasrc/Nodes/Internal"
nodeList = []
for root, dirs, files in os.walk(nodeDir):
    for file in files:
        if file == "display_data.json":
             continue
        
        if file.endswith(".json"):
            nodeList.append(os.path.join(root, file))

# %% Generate contents
nodeContent  = {}
nodeMetadata = {}
nodeTags     = {}

for nodePath in tqdm(nodeList, desc="Generating node content"):
    with open(nodePath, 'r') as f:
        nodeMeta = json.load(f)

    if not nodeMeta:
        print(f"Invalid Node metadata for {nodePath}.")
        continue
    
    nodeBase = nodeMeta["baseNode"]
    nodeName = nodeMeta["name"]
    
    # placeholderPath = f"docsdata/content/__nodes/{fileUtil.pathSanitize(nodeBase)}"
    # if not os.path.exists(placeholderPath + ".html"):
    #     fileUtil.verifyFile(placeholderPath + ".md")

    contentPath = f"docsdata/pregen/__nodes/{fileUtil.pathSanitize(nodeBase)}.html"

    changedPath = f"docsdata/content/__nodes/__changes/{fileUtil.pathSanitize(nodeBase)}.json"
    changeData  = None
    if os.path.exists(changedPath):
        with open(changedPath, "r") as f:
            changeData = json.load(f)

    content = nodeWriter.writeNode(nodeMeta, contentPath, changeData)

    if not content:
        print(f"Cannot write content for {nodeBase}.")
        continue

    nodeContent[nodeBase]  = content
    nodeMetadata[nodeBase] = nodeMeta
    nodeMetadata[nodeBase.lower()] = nodeMeta

    tags = nodeMeta["tags"] if "tags" in nodeMeta else []
    for tag in tags:
        if tag not in nodeTags:
            nodeTags[tag] = []
        nodeTags[tag].append(nodeBase)

# %% Write content to file using category
targetRoot = "docsdata/pregen/3_nodes"
fileUtil.verifyFile("docs/nodes/_index/index.html", f'''<!DOCTYPE html><html></html>''')
fileUtil.verifyFolder(targetRoot)

nodeCategoryDir = "datasrc/Nodes/Internal/display_data.json"
with open(nodeCategoryDir, 'r') as f:
    nodeCategoryData = json.load(f)

nodeCategory  = {}
categoryIndex = 0
specialCategory = {
    "PCX": [ "pcx_variable", "pcx_functions", "pcx_flow_control" ],
    "Iteration": [ "iterate", "iterate_inline", "iterate_each", "iterate_each_inline", "iterate_filter", "iterate_filter_inline" ],
    "Particle": [ "psystem", "psystem_3d", "vfx" ],
    "Simulation": [ "rigidsim", "smokesim", "flip_fluid", "strandsim", "verletsim" ],
}

spmap = {}
spindex = 0
for sp, nodes in specialCategory.items():
    nodeindex = 0
    for node in nodes:
        spmap[node] = (sp, spindex + 200, nodeindex)
        nodeindex += 1
    spindex += 1

for category in nodeCategoryData:
    cName  = category["iname"] if "iname" in category else category["name"]
    cNodes = category["nodes"]
    cContext = category["context"] if "context" in category else None
    if not cNodes:
        continue

    nodeCategory[cName] = cNodes
    
    sortIndex = categoryIndex
    if cContext:
        sortIndex += 100

    categoryDir = os.path.join(targetRoot, f"{sortIndex:03}_{fileUtil.pathSanitize(cName)}")
    spkey = cName.lower().replace(" ", "_")
    if spkey in spmap:
        spgroup = spmap[spkey]
        categoryDir = os.path.join(targetRoot, f"{spgroup[1]:03}_{spgroup[0]}")
        categoryDir = os.path.join(categoryDir, f"{spgroup[2]:03}_{fileUtil.pathSanitize(cName)}")
    fileUtil.verifyFolder(categoryDir)

    categoryContent  = f'''<!DOCTYPE html><html></html>{VERSION}'''
    categoryContent += nodeWriter.writeCategory(category, nodeMetadata)
    fileUtil.writeFile(f"{categoryDir}/index.html", categoryContent)
    categoryIndex += 1

    subgroupCurrent    = None
    subgroupIndex      = 0
    subsubGroupCurrent = None
    subsubGroupIndex   = 0

    for node in cNodes:
        if not isinstance(node, str):
            if "label" not in node:
                continue

            subgroup = node["label"]
            if subgroup.startswith("/"):
                subsubGroup = subgroup.strip("/")
                if subsubGroup != subsubGroupCurrent:
                    subsubGroupCurrent = subsubGroup
                    subsubGroupIndex += 1
                continue
            
            if subgroup  != subgroupCurrent:
                subgroupCurrent = subgroup
                subgroupIndex += 1

                subsubGroupCurrent = None
                subsubGroupIndex   = 0
            continue

        if node not in nodeContent:
            print(f"Node content for {node} not found.")
            continue
        
        fname = fileUtil.pathSanitize(node)
        fname = fname.replace("node_", "")

        currentDir = categoryDir
        if subgroupCurrent != None:
            currentDir = os.path.join(categoryDir, f"{subgroupIndex}_{fileUtil.pathSanitize(subgroupCurrent)}")
            fileUtil.verifyFolder(currentDir)
            fileUtil.verifyFile(f"{currentDir}/index.html", f'''<!DOCTYPE html><html></html>''')

            if subsubGroupCurrent != None:
                currentDir = os.path.join(currentDir, f"{subsubGroupIndex}_{fileUtil.pathSanitize(subsubGroupCurrent)}")
                fileUtil.verifyFolder(currentDir)
                fileUtil.verifyFile(f"{currentDir}/index.html", f'''<!DOCTYPE html><html></html>''')
        
        targetPath = os.path.join(currentDir, fname + ".html")
        fileUtil.writeFile(targetPath, nodeContent[node])
        
        nodeMeta = nodeMetadata[node]
        nodeName = fileUtil.pathSanitize(nodeMeta["name"])
        nodeBase = nodeMeta["baseNode"]

        redirPath = targetPath.replace("docsdata/pregen/3_nodes", "/nodes")
        redir     = f'''<!DOCTYPE html><html><meta http-equiv="refresh" content="0; url={redirPath}"/></html>'''
        
        fileUtil.writeFile(f"docs/nodes/_index/{nodeName}.html", redir)
        fileUtil.writeFile(f"docs/nodes/_index/{nodeBase}.html", redir)

# %% Write tag pages
tagDir = os.path.join(targetRoot, "_tags")
fileUtil.verifyFolder(tagDir)

for tag, nodes in nodeTags.items():
    tagContent = f'''<!DOCTYPE html><html></html>{VERSION}'''
    tagContent += nodeWriter.writeTag(tag, nodes, nodeMetadata)
    fileUtil.writeFile(os.path.join(tagDir, f"{fileUtil.pathSanitize(tag)}.html"), tagContent)

# %% Replace node tags
root = "docsdata/pregen"
for root, dirs, files in os.walk(root):
    for file in files:
        if not file.endswith(".html"):
            continue
        
        path = os.path.join(root, file)
        with open(path, "r") as f:
            content = f.read()

        nodeTags = re.findall(r'<node\s(.*?)>', content)
        for tag in nodeTags:
            name = tag.strip("/").replace(" ", "_").lower()
            if not name.startswith("node_"):
                name = "node_" + name
            if name not in nodeMetadata:
                print(f"Node {name} not found for tag replacement in <node {tag}>.")
                continue
            
            meta = nodeMetadata[name]
            nodeBase = meta["baseNode"]
            nodeName = meta["name"]

            content = content.replace(f'<node {tag}>', f'<a class="node" href="/nodes/_index/{nodeBase}.html">{nodeName}</a>')

        with open(path, "w") as f:
            f.write(content)