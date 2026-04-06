# %% 
import os
import re

shortDict = {
    "a":  "area",
    "c":  "color",
    "b":  "bool",
    "cu": "curve",
    "es": "enum_scroll",
    "eb": "enum_button",
    "f":  "float",
    "gr": "gradient",
    "i":  "int",
    "pl": "palette",
    "pn": "pathnode",
    "rn": "range",
    "r":  "rotation",
    "s":  "slider",
    "sr": "surface",
    "tr": "trigger",
    "2":  "vec2",
}

# %%
def reFindFirst(pattern, string):
    match = re.search(pattern, string)
    if match:
        return match.group(1)
    return ""

def parseInput(inp):
    inp   = inp.strip()
    iName = reFindFirst(r'"(.*?)"', inp)
    iType = reFindFirst(r"^.*nodeValue(.*?)\(", inp).strip(" _").lower()

    if iType in shortDict:
        iType = shortDict[iType]

    if iType == "dimension":
        iName = "dimension"
        iType = "dimension"

    if "enum" in iType:
        iType = "enum"

    return {
        "name": iName,
        "type": iType, 
    }

def parseInputs(inputs):
    return [parseInput(i) for i in inputs]
# %%

def parseOutput(out):
    out   = out.strip()
    oName = reFindFirst(r'"(.*?)"', out)
    oType = reFindFirst(r"^.*VALUE_TYPE\.(.*?)\,", out).strip(" _").lower()

    return {
        "name": oName,
        "type": oType, 
    }

def parseOutputs(outputs):
    return [parseOutput(o) for o in outputs]
# %%
