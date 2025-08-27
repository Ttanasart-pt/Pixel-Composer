import os
import subprocess
import re

yycTemplate = """{{
  "$GMExtension":"",
  "%Name": "inlineC",
  "androidactivityinject":null,
  "androidclassname":"",
  "androidcodeinjection":"",
  "androidinject":null,
  "androidmanifestinject":null,
  "androidPermissions":[],
  "androidProps":false,
  "androidsourcedir":"",
  "author":"",
  "classname":"",
  "copyToTargets":-1,
  "description":"",
  "exportToGame":true,
  "extensionVersion":"0.0.1",
  "files":[ {files} ],
  "gradleinject":null,
  "hasConvertedCodeInjection":false,
  "helpfile":"",
  "HTML5CodeInjection":"",
  "html5Props":false,
  "IncludedResources":[],
  "installdir":"",
  "iosCocoaPodDependencies":"",
  "iosCocoaPods":"",
  "ioscodeinjection":"",
  "iosdelegatename":"",
  "iosplistinject":null,
  "iosProps":false,
  "iosSystemFrameworkEntries":[],
  "iosThirdPartyFrameworkEntries":[],
  "license":"",
  "maccompilerflags":"",
  "maclinkerflags":"",
  "macsourcedir":"",
  "name": "inlineC",
  "options":[],
  "optionsFile":"options.json",
  "packageId":"",
  "parent":{{
    "name":"functions",
    "path":"folders/__extensions/functions.yy",
  }},
  "productId":"",
  "resourceType":"GMExtension",
  "resourceVersion":"2.0",
  "sourcedir":"",
  "supportedTargets":-1,
  "tvosclassname":null,
  "tvosCocoaPodDependencies":"",
  "tvosCocoaPods":"",
  "tvoscodeinjection":"",
  "tvosdelegatename":null,
  "tvosmaccompilerflags":"",
  "tvosmaclinkerflags":"",
  "tvosplistinject":null,
  "tvosProps":false,
  "tvosSystemFrameworkEntries":[],
  "tvosThirdPartyFrameworkEntries":[],
}}"""

yycfunctionTemplate = """{{
  "$GMExtensionFile":"",
  "%Name":"",
  "constants":[],
  "copyToTargets":-1,
  "filename":"dll/{dllName}",
  "final":"",
  "functions":[ 
    {{"$GMExtensionFunction":"","%Name":"{func_name}","argCount":0,"args":{iArray},"documentation":"","externalName":"{func_name}","help":"","hidden":false,"kind":1,"name":"{func_name}","resourceType":"GMExtensionFunction","resourceVersion":"2.0","returnType":{oType}}}
  ],
  "init":"",
  "kind":1,
  "name":"",
  "order":[],
  "origname":"",
  "ProxyFiles":[
    {{"$GMProxyFile":"","%Name":"dll/{dllNameW}","name":"dll/{dllNameW}","resourceType":"GMProxyFile","resourceVersion":"2.0","TargetMask":6,}},
    {{"$GMProxyFile":"","%Name":"dll/{dllNameL}","name":"dll/{dllNameL}","resourceType":"GMProxyFile","resourceVersion":"2.0","TargetMask":7,}},
  ],
  "resourceType":"GMExtensionFile",
  "resourceVersion":"2.0",
  "uncompress":false,
  "usesRunnerInterface":false
}}"""

def compileFile(srcPath, outDir):
    print(f"Compiling {srcPath}...")
    
    objPath = os.path.splitext(srcPath)[0] + ".o"
    outName = os.path.splitext(os.path.basename(srcPath))[0]
    outPathW = os.path.join(outDir, outName + ".dll")
    outPathL = os.path.join(outDir, outName + ".so")

    gccPath = "C:\\MinGW\\bin\\gcc"
    gccPath = "C:\\mingw64\\bin\\gcc" # 64-bit

    # cmd = [ gccPath, "-fpic", "-shared", srcPath, "-o", outPath, "-Wl,--subsystem,windows"]

    cmd = [ gccPath, "-c", srcPath, "-o", objPath ]
    try:
        subprocess.run(cmd, capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        print("Failed to run command: " + " ".join(cmd))
        print("Compilation errors:" + e.stderr + "|")
        raise Exception(f"Compilation failed: {e.stderr}")

    cmd = [ gccPath, "-shared", objPath, "-o", outPathW, "-Wl,--subsystem,windows"]
    try:
        subprocess.run(cmd, capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        print("Failed to run command: " + " ".join(cmd))
        print("Linking errors:" + e.stderr + "|")
        raise Exception(f"Linking failed: {e.stderr}")
    
    cmd = [ gccPath, "-shared", objPath, "-o", outPathL ]
    try:
        subprocess.run(cmd, capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        print("Failed to run command: " + " ".join(cmd))
        print("Linking errors:" + e.stderr + "|")
        raise Exception(f"Linking failed: {e.stderr}")

    os.remove(objPath)
    return {
        "windows": outPathW,
        "linux": outPathL
    }

def buildInline(string):
    full_code  = "#define function extern \"C\" __declspec(dllexport)\n"
    full_code += string
    
    lines  = string.splitlines()
    header = ""
    for line in lines:
        line = line.strip()
        if line.startswith("function "):
            header = line[len("function "):].strip()
            break

    otype, fnSignature = header.strip().split(" ", 1)
    fname, fparams = fnSignature.split("(", 1)
    fparams = fparams.rsplit(")", 1)[0]

    inputs = []
    paramList = fparams.split(",")
    for param in paramList:
        ptype, pname = param.rsplit(" ", 1)
        inputs.append((ptype.strip(), pname.strip()))

    return {
        "code": full_code,
        "func_name": fname.strip(),
        "return_type": otype.strip(),
        "inputs": inputs
    }

def scanInline(src):
    functions = []
    lines = src.splitlines()
    i = 0

    while i < len(lines):
        line = lines[i].strip()

        if line.startswith("/*[cpp]"):
            inline_code = line[7:].strip() + "\n"
            i += 1
            while i < len(lines):
                line = lines[i].strip()
                if line == "*/":
                    break
                inline_code += line + "\n"
                i += 1
            
            functions.append(buildInline(inline_code))
        i += 1
    return functions

def scanFolder(folder):
    srcArr = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.endswith(".gml"):
                filePath = os.path.join(root, file)
                with open(filePath, 'r', encoding='utf-8') as f:
                    src = f.read()
                funcs = scanInline(src)
                srcArr.extend(funcs)
    return srcArr

def buildExtension(srcArr, extDir):
    extYYPath = os.path.join(extDir, "inlineC.yy")
    
    if not os.path.isfile(extYYPath):
        raise Exception("Extension definition file does not exist: " + extYYPath)
    
    srcDir = os.path.join(extDir, "src")
    if not os.path.isdir(srcDir):
        os.makedirs(srcDir)

    dllDir = os.path.join(extDir, "dll")
    if not os.path.isdir(dllDir):
        os.makedirs(dllDir)

    files  = [];

    for src in srcArr:
        code = src["code"]
        func_name = src["func_name"]
        return_type = src["return_type"]
        inputs = src["inputs"]

        srcPath = os.path.join(srcDir, f"{func_name}.cpp")
        with open(srcPath, 'w') as f:
            f.write(code)

        dllPath = compileFile(srcPath, dllDir)
        dllPathW = dllPath["windows"]
        dllPathL = dllPath["linux"]

        dllName = os.path.basename(dllPathW)

        iArray = [2 if t == "double" else 1 for t, n in inputs]
        oType  = 2 if return_type == "double" else 1

        fnEntry = yycfunctionTemplate.format(
            dllName=dllName,
            dllNameW=os.path.basename(dllPathW),
            dllNameL=os.path.basename(dllPathL),
            func_name=func_name,
            iArray=iArray,
            oType=oType
        )

        files.append(fnEntry)
            
    yyString = yycTemplate.format(
        files=",".join(files)
    )

    with open(extYYPath, 'w') as f:
        f.write(yyString)

if __name__ == "__main__":
    scriptDir = "D:\\Project\\MakhamDev\\LTS-PixelComposer\\PixelComposer\\scripts"
    extDir = "D:\\Project\\MakhamDev\\LTS-PixelComposer\\PixelComposer\\extensions\\inlineC"

    srcArr = scanFolder(scriptDir)
    buildExtension(srcArr, extDir)