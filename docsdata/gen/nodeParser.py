# %% 
import os
import re
from tqdm import tqdm

import juncParser

scriptDir   = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/scripts"
nodeScripts = {}
nodeLists   = []
nodeData    = {}

# %%
def reFindFirst(pattern, string):
    match = re.search(pattern, string)
    if match:
        return match.group(1)
    return ""

#%%
def readNodeScripts():
    scripts = {}

    for _dir in os.listdir(scriptDir):
        if not os.path.isdir(os.path.join(scriptDir, _dir)):
            continue
        
        if not _dir.lstrip("_").startswith("node_"):
            continue
        
        scriptFile = f"{scriptDir}/{_dir}/{_dir}.gml"
        if not os.path.exists(scriptFile):
            continue

        with open(scriptFile, "r") as f:
            script = f.read()
        
        baseNode = reFindFirst(r"function\s(Node\w*)\(.*?constructor", script).strip()
        if not baseNode:
            continue
        if not baseNode.lstrip("_").lower().startswith("node_"):
            continue

        scripts[baseNode] = script

    return scripts

nodeScripts = readNodeScripts()
nodeLists   = list(nodeScripts.keys())

# %%
def readNodeFile(baseNode):
    if baseNode not in nodeScripts:
        print(f"Node script for {baseNode} not found.")
        return None
    
    script = nodeScripts[baseNode]
    
    classParent = reFindFirst(r"function.*:\s(\w*)", script).strip()

    inputs = re.findall(r"^\s*newInput\((?!index).*$", script, re.MULTILINE)
    inputs = juncParser.parseInputs(inputs)

    inputDynamic = re.findall(r"^\s*newInput\(index.*$", script, re.MULTILINE)
    inputDynamic = juncParser.parseInputs(inputDynamic)

    outputs = re.findall(r"^\s*newOutput.*$", script, re.MULTILINE)
    outputs = juncParser.parseOutputs(outputs)

    data = {
        "name":        baseNode,
        "classParent": classParent,
        "inheritances":[],

        "inputs":      inputs,
        "inputDynamic":inputDynamic,
        "outputs":     outputs,
        "categories":  [],
        "attributes":  [],
    }

    return data

for baseNode in tqdm(nodeLists, desc="Reading node files"):
    nodeData[baseNode] = readNodeFile(baseNode)

# %% 
def inheritancesIterate(baseNode):
    if baseNode not in nodeData:
        print(f"Node data for {baseNode} not found.")
        return None
    
    inheritances = [nodeData[baseNode]]
    currentNode  = baseNode

    while True:
        data    = nodeData[currentNode]
        cparent = data["classParent"]

        if cparent == "" or cparent not in nodeData:
            break

        inheritances.insert(0, nodeData[cparent])

        if data["classParent"] == "node":
            break
        
        currentNode = data["classParent"]
    
    nodeData[baseNode]["inheritances"] = inheritances

for baseNode in tqdm(nodeLists, desc="Iterating inheritances"):
    inheritancesIterate(baseNode)

# %%
def getNodeData(baseNode):
    if baseNode not in nodeData:
        print(f"Node data for {baseNode} not found.")
        return None
    
    return nodeData[baseNode]

