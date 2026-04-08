# %%
import os
import re
import fileUtil

import nodeParser
import juncWriter

with open("docsdata/templates/node.html", "r") as f:
    template = f.read()

def generateBadge(title, tooltip, color, page = ""):
    style = f"color: #{color}; background-color: #{color}16; border-color: #{color}60;"
    return f'<a href="{page}" class="badge" style="{style}" title="{tooltip}">{title}</a>'

def generateBasicData(nodeData, metadata):  
    nodeName   = metadata["name"]
    node       = metadata["baseNode"]
    spr        = metadata["spr"]     if "spr" in metadata else f"s_{node.lower()}"
    
    categories = nodeData["categories"]
    parents    = nodeData["inheritances"]

    basicData = '<tr><th class="head first" colspan="2"><p>Node Data</p></th></tr>'
    basicData += f'<tr><th colspan="2"><img {spr}></th></tr>'

    badges = ""
    for btitle, bdesp, bcolor, bpage in categories:
        badges += generateBadge(btitle, bdesp, bcolor, bpage)

    if badges != "":
        basicData += '<tr style="height: 4px;"></tr>'
        basicData += f'<tr><th colspan="2">{badges}</th></tr>'
        basicData += '<tr style="height: 8px;"></tr>'

    basicData += f'<tr><th colspan="2" class="summary-topic"><p class="subtopic">Display name</p></th></tr>'
    basicData += f'<tr><th colspan="2" class="summary-content"><p>{nodeName}</p></th></tr>'
    
    basicData += f'<tr><th colspan="2" class="summary-topic"><p class="subtopic">Internal name</p></th></tr>'
    basicData += f'<tr><th colspan="2" class="summary-content"><p>{node}</p></th></tr>'

    if "tags" in metadata:
        basicData += f'<tr><th colspan="2" class="summary-tag"><div>'
        for tag in metadata["tags"]:
            href = f"/nodes/_tags/{fileUtil.pathSanitize(tag)}.html"
            basicData += f'<a href="{href}">{tag}</a>'
        basicData += '</div></th></tr>'
    
    basicData += '<tr height="8px"></tr>'
    basicData += '<tr><th class="head" colspan="2"><p>Inheritances</p></th></tr>'

    for i, p in enumerate(parents):
        pName = p["name"]
        link  = ""

        if pName == "Node":
            link = "/nodes/index.html"
        elif pName == "Node_Processor":
            link = "/nodes/array_processor.html"
        else:
            link = f"/nodes/_index/{pName}.html"
        
        _class = "inheritance-block"
        if i == len(parents) - 1:
            _class = "inheritance-block current"
            link   = "#"

        basicData += f'<tr><th colspan="2" class="{_class}"><a href="{link}">{pName}</a></th></tr>'
    return basicData

def applySummaryTable(basicData, junctionText, attributeText):
    return basicData + '<tr height="8px"></tr>' + \
           junctionText +                         \
           attributeText

def applyTemplate(template, nodeName, tooltip, summary):
    return template.replace("{{nodeName}}", nodeName) \
                   .replace("{{tooltip}}",  tooltip)  \
                   .replace("{{summary}}",  summary)

def writeChangeTable(metadata, changeData):
    nodeName = metadata["name"]
    hasAnyChange = False

    changeText = '''
<br><h2>Commit History</h2><br>
<table class="change-table">'''
    for change in changeData:
        version = change["version"]
        changes = change["changes"]
        changeTextV = f'<tr><th>{version}</th></tr>'
        hasChanges  = False

        for c in changes:
            commit  = c["commit"]
            node    = c["node"]
            if(node != nodeName):
                continue
            if(commit.startswith("Fix")):
                continue

            changeTextV += f'<tr><td>{commit}</td></tr>'
            hasChanges = True

        if hasChanges:
            changeText += changeTextV
            hasAnyChange = True

    changeText += '</table>'
    if not hasAnyChange:
        return ""
    return changeText

def writeNode(metadata, rawContent, changeData = None):
    nodeName = metadata["name"]
    nodeBase = metadata["baseNode"]
    tooltip  = metadata["tooltip"] if "tooltip" in metadata else ""
    nodeData = nodeParser.getNodeData(nodeBase)

    if not nodeData:
        print(f"Node data for {nodeBase} not found.")
        return None
    
    basicData     = generateBasicData(nodeData, metadata)
    junctionText  = juncWriter.IOTable(nodeData)
    attributeText = juncWriter.AttributeTable(nodeData)

    summary  = applySummaryTable(basicData, junctionText, attributeText)
    content  = applyTemplate(template, nodeName, tooltip, summary)

    junctions = {}
    for junc in nodeData["inputs"] + nodeData["outputs"]:
        jName = junc["name"].lower()
        junctions[jName] = junc

    juncTags = re.findall(r'<junc\s(.*?)>', rawContent)
    for tag in juncTags:
        jName = tag.strip("/").lower()
        
        if jName == "": 
            continue

        if jName in junctions:
            jColor  = juncWriter.getColor(junctions[jName]["type"])
            rawContent = rawContent.replace(f'<junc {tag}>', f'<span class="junction" style="border-color: {jColor}AA">{jName.title()}</span>')
        else:
            rawContent = rawContent.replace(f'<junc {tag}>', f'<span class="junction">{jName.title()}</span>')

    attrTags = re.findall(r'<attr\s(.*?)/>', rawContent)
    for tag in attrTags:
        rawContent = rawContent.replace(f'<attr {tag}/>', f'<span class="inline-code">{tag}</span>')

    content += rawContent
    if changeData:
        content += writeChangeTable(metadata, changeData)

    return content

# %%
group_start = '''<div class="node-group">'''
group_end   = '''</div>'''

def writeCategory(category, nodeMetadata):
    name  = category["name"]
    nodes = category["nodes"]

    title   = name
    content = f"""<h1>{title}</h1><br><br>"""
    nl = True
    
    for node in nodes:
        if not isinstance(node, str):
            subGroup = node["label"]
            sgName   = subGroup.strip("/")
            subsubGroup = subGroup.startswith("/")

            if not nl:
                content += group_end

            if subsubGroup:
                content += f'<h5 class="node-group-title">{sgName}</h5>'
            else:
                if not nl:
                    content += "</div>"
                content += '<div class="node-category">'
                content += f'<h3 class="node-group-title">{sgName}</h3>'

            nl = True
            continue

        if node not in nodeMetadata:
            print(f"Node content for {node} not found.")
            continue
        
        if nl:
            content += group_start
            nl = False

        metadata = nodeMetadata[node]
        name     = metadata["name"]
        spr      = metadata["spr"]  if "spr" in metadata else f"s_{node.lower()}"

        content += f'''<div class="node-card"><a href="./{node.lower().replace("node_", "")}.html"><img {spr}>{name}</a></div>\n'''

    if not nl:
        content += group_end
    return content

def writeTag(tag, nodes, nodeMetadata):
    title    = f"Tag: {tag}"
    content  = f"""<h1>{title}</h1><br><br>"""
    content += '<div class="node-category">'
    content += f'<h3 class="node-group-title">Nodes</h3>'
    content += '<div class="node-group">'

    for node in nodes:
        if node not in nodeMetadata:
            print(f"Node metadata for {node} not found.")
            continue
        
        metadata = nodeMetadata[node]
        name     = metadata["name"]
        spr      = metadata["spr"]  if "spr" in metadata else f"s_{node.lower()}"
        nodeName = fileUtil.pathSanitize(name)

        content += f'''<div class="node-card"><a href="/nodes/_index/{nodeName}.html"><img {spr}>{name}</a></div>\n'''
    
    content += '</div></div>'
    return content