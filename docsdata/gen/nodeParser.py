# %% 
import os
import re
from tqdm import tqdm

import juncParser

scriptDir   = "scripts"
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

    inputs = []
    inputDynamic = []
    outputs = []

    dynamicInputCapture = re.findall(r"function\screateNewInput.*\{([\s\S]*?)\n\s*\}", script)
    if dynamicInputCapture:
        dynamicInputCapture = dynamicInputCapture[0]
        script = script.replace(dynamicInputCapture, "")
        
        inputDynamic = re.findall(r"^\s*newInput.*$", dynamicInputCapture, re.MULTILINE)
        inputDynamic = juncParser.parseInputs(inputDynamic)

    _inputs = re.findall(r"(^\s*newInput.*$)|(^\s*\/{4}-\s=.*$)", script, re.MULTILINE)
    for _input in _inputs:
        inputs.extend(_input)
    inputs  = juncParser.parseInputs(inputs)
    inputs  = [i for i in inputs if i["name"] != ""]

    outputs = re.findall(r"^\s*newOutput.*$", script, re.MULTILINE)
    outputs = juncParser.parseOutputs(outputs)

    shaderMatch = re.findall(r"\s(sh_\w+)", script)
    shaders = list(set(shaderMatch))
    
    attrs = []
    if script.find('attribute_surface_depth') != -1: attrs.append("Color Depth")
    if script.find('attribute_interpolation') != -1: attrs.append("Interpolation")
    if script.find('attribute_oversample') != -1:    attrs.append("Oversample")

    data = {
        "name":        baseNode,
        "classParent": classParent,
        "inheritances":[],

        "inputs":      inputs,
        "inputDynamic":inputDynamic,
        "outputs":     outputs,
        "categories":  [],
        "attributes":  attrs,

        "shaders":     shaders
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

