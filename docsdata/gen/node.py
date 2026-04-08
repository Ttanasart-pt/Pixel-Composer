# %%
import os
import re
import fileUtil
import json5 as json
from tqdm import tqdm

import nodeWriter

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
        nodeName = fileUtil.pathSanitize(nodeMeta["name"])
        nodeBase = nodeMeta["baseNode"]
        redir    = f'''<!DOCTYPE html><html><meta http-equiv="refresh" content="0; url=/nodes/{cName.lower()}/{fname}.html"/></html>'''
        
        with open(f"docs/nodes/_index/{nodeName}.html", "w") as file:
            file.write(redir)
        
        with open(f"docs/nodes/_index/{nodeBase}.html", "w") as file:
            file.write(redir)

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