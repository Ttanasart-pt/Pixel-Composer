# %%
import re

dispIndex = {
    "dimension"       : "integer",
    "enum"            : "integer",
    "enum_button"     : "integer",
    "enum_scroll"     : "integer",
    "int"             : "integer",
    "toggle"          : "integer",
    "islider"         : "float",

    "area"            : "float",
    "corner"          : "float",
    "padding"         : "float",
    "palette"         : "color",
    "path_anchor"     : "float",
    "path_anchor_3d"  : "float",
    "quaternion"      : "float",
    "range"           : "float",
    "rotation"        : "float",
    "rotation_random" : "float",
    "rotation_range"  : "float",
    "slider_range"    : "float",
    "vec2"            : "float",
    "vec2_range"      : "float",
    "vec3"            : "float",
    "vec3_range"      : "float",
    "vec4"            : "float",
    "vector"          : "float",
    "slider"          : "float",

    "bool"            : "boolean",
}

# %%
typeIndex = {}
typeColor = []
typeScriptPath = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/scripts/node_value_types/node_value_types.gml"
with open(typeScriptPath, "r") as f:
    typeData = f.read()

_val_types = re.findall(r"enum VALUE_TYPE {(.*?)}", typeData, re.MULTILINE | re.DOTALL)
for _val_type in _val_types:
    lines = _val_type.splitlines()
    for line in lines:
        line = line.strip().strip(",")
        if not line or line.startswith("//"):
            continue

        name, value = line.split("=")
        name  = name.strip().lower()
        value = int(value.strip())

        typeIndex[name] = value

_val_colors = re.findall(r"JUNCTION_COLORS = \[(.*?)\]", typeData, re.MULTILINE | re.DOTALL)
for _val_color in _val_colors:
    lines = _val_color.splitlines()
    for line in lines:
        line = line.strip()
        if not line or line.startswith("//"):
            continue
        
        line  = line.split("//")[0].strip().strip(",")
        color = line

        typeColor.append(color)

# %%
def getColor(dataType):
    dtype = dataType
    if dtype in dispIndex:
        dtype = dispIndex[dtype]

    if dtype not in typeIndex:
        return "#8fde5d"

    ind = typeIndex[dtype]
    if ind >= len(typeColor) or ind < 0:
        return "#8fde5d"
    
    return typeColor[ind]

def IOTable(nodeData):
    inheritances = nodeData["inheritances"]
    inputRows  = ""
    outputRows = ""
    allio      = {}
    
    for node in inheritances:
        _name    = node["name"]
        _inputs  = node["inputs"]
        _inputDy = node["inputDynamic"]
        _outputs = node["outputs"]
        
        for _junc in _inputs:
            allio[_junc["name"]] = getColor(_junc["type"])
        
        for _junc in _outputs:
            allio[_junc["name"]] = getColor(_junc["type"])

        if _inputs:
            inputRows += f'<tr><th colspan="2" class="summary-topic"><p>{_name}</p></th></tr>'

        for _junc in _inputs:
            # mapStr = "" if not _mappable else '<a href="/nodes/junctions/mappable.html" style="line-height: 1;"><img mappable></a>'
            mapStr = ""
            jName  = _junc["name"]
            jType  = _junc["type"]

            inputRows += f"""<tr>
                <td class="summary-topic" style="width: 60px"><p style="color: {getColor(jType)}">{jType}</p></td>
                <td><p>{jName.title()}{mapStr}</p></td>
            </tr>"""

        if _inputDy:
            dynamicTable = f'''<table class="summary-table dynamic" style="margin-top: 8px;"><tr>
                <th colspan="2" class="summary-topic">
                    <p style="margin: -0.85rem auto -4px auto;width: fit-content;padding: 0px 8px;">Dynamic Inputs</p>
                </th>
            </tr>'''

            for _junc in _inputDy:
                jName  = _junc["name"]
                jType  = _junc["type"]

                dynamicTable += f"""<tr>
                    <td class="summary-topic" style="width: 60px"><p style="color: {getColor(jType)}" >{jType}</p></td>
                    <td><p>{jName.title()}</p></td>
                </tr>"""

            dynamicTable += "</table>"
            inputRows    += f"""<tr><td colspan="2">{dynamicTable}</td></tr>"""

        if _outputs:
            outputRows += f'<tr><th colspan="2" class="summary-topic"><p>{_name}</p></th></tr>'

        for _junc in _outputs:
            jName  = _junc["name"]
            jType  = _junc["type"]

            outputRows += f"""<tr>
                <td class="summary-topic" style="width: 60px"><p style="color: {getColor(jType)}">{jType}</p></td>
                <td><p>{jName.title()}</p></td>
            </tr>"""

    summaryTxt = f"""
<tr><th class="head" colspan="2"><p>Inputs</p></th></tr>
{inputRows}
<tr height="8px"></tr>
<tr><th class="head" colspan="2"><p>Outputs</p></th></tr>
{outputRows}
"""
    
    return summaryTxt

def AttributeTable(nodeData):
    attributes = []
    attrList   = nodeData["attributes"]
    rows       = ""

    for node, attrs in attrList:
        if attrs:
            rows += f'<tr><th colspan="2" class="summary-topic"><p>{node}</p></th></tr>'
            rows += "".join([f"""<tr><td colspan="2" class="summary-attribute"><p>{_attr}</p></td></tr>""" for _attr in attrs])

        attributes.append(attrs)
    
    if rows == "":
        return ""
    
    summaryTxt = f"""
<tr><th class="head" colspan="2"><p>Attributes</p></th></tr>
{rows}
"""

    return summaryTxt