import os
import subprocess
import re
import hashlib

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
  "copyToTargets":192,
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
  "supportedTargets":105554172285166,
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

yycfileTemplate = """{{
  "$GMExtensionFile":"",
  "%Name":"",
  "constants":[],
  "copyToTargets":192,
  "filename":"{dllName}",
  "final":"",
  "functions":[{functions} ],
  "init":"",
  "kind":1,
  "name":"",
  "order":[],
  "origname":"",
  "ProxyFiles":[
    {{"$GMProxyFile":"","%Name":"{dllNameW}","name":"{dllNameW}","resourceType":"GMProxyFile","resourceVersion":"2.0","TargetMask":6,}},
    {{"$GMProxyFile":"","%Name":"{dllNameL}","name":"{dllNameL}","resourceType":"GMProxyFile","resourceVersion":"2.0","TargetMask":7,}},
  ],
  "resourceType":"GMExtensionFile",
  "resourceVersion":"2.0",
  "uncompress":false,
  "usesRunnerInterface":false
}},"""

yycfunctionTemplate = """{{"$GMExtensionFunction":"","%Name":"{func_name}","argCount":{iCount},"args":{iArray},"documentation":"","externalName":"{func_name}","help":"","hidden":false,"kind":1,"name":"{func_name}","resourceType":"GMExtensionFunction","resourceVersion":"2.0","returnType":{oType}}},"""

def get_msvc_env(vcvars_path):
    # Run vcvars64.bat and dump environment variables to a temp file
    dump_env = 'set > "%temp%\\msvc_env.txt"'
    cmd = f'cmd /c ""{vcvars_path}" && {dump_env}"'
    subprocess.run(cmd, shell=True)
    env_file = os.path.expandvars(r'%temp%\msvc_env.txt')
    env = {}
    with open(env_file) as f:
        for line in f:
            if '=' in line:
                k, v = line.strip().split('=', 1)
                env[k] = v
    return env

vcvars_path = "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Auxiliary\\Build\\vcvars64.bat"
msvc_env = get_msvc_env(vcvars_path)

def compile_with_msvc(src_file, out_dll):
    msvcPath = "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.44.35207\\bin\\Hostx64\\x64\\cl.exe"
    cmd = [
        msvcPath,
        '/LD',
        src_file,
        f'/Fe:{out_dll}',
        "/EHsc" # Enable C++ exceptions
    ]
    # Use the captured environment
    result = subprocess.run(cmd, env={**os.environ, **msvc_env}, shell=True)

    base = os.path.splitext(out_dll)[0]
    for ext in ['.lib', '.exp']:
        try:
            os.remove(base + ext)
        except FileNotFoundError:
            pass
    
    return result.returncode == 0

srcCache = set()

def getFileHash(filePath):
    hasher = hashlib.md5()
    with open(filePath, 'rb') as f:
        buf = f.read()
        hasher.update(buf)
    return hasher.hexdigest()

def executeCmd(cmd):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print("Failed to run command: " + " ".join(cmd))
        print("Error output:" + e.stderr + "|")
        raise Exception(f"Command failed: {e.stderr}")

def compileFile(srcPath, outDir, _):
    
    outName  = os.path.splitext(os.path.basename(srcPath))[0]
    objPath  = os.path.join(outDir, outName + ".o")
    outPathW = os.path.join(outDir, outName + ".dll")
    outPathL = os.path.join(outDir, outName + ".so")

    fhash = getFileHash(srcPath)
    if fhash in srcCache:
        print(f"Skipping compilation for {outName}, no changes detected.")
        return {
            "windows": outPathW,
            "linux": outPathL
        }
    
    print(f"Compiling {outName}...")
    
    flags = ["-static-libgcc", "-static-libstdc++"]

    if os.path.isfile(outPathW):
        os.remove(outPathW)

    if os.path.isfile(outPathL):
        os.remove(outPathL)

    # gccPath = "C:\\mingw64\\bin\\g++" # 64-bit
    # cmd = [ gccPath, "-fpic", "-shared", srcPath, "-o", outPathW, "-Wl,--subsystem,windows", "-m64"]
    # cmd.extend(flags)
    # executeCmd(cmd)

    compile_with_msvc(srcPath, outPathW)

    if os.path.isfile(objPath):
        os.remove(objPath)

    srcMntPath  = re.sub(r'^[A-Za-z]:', lambda m: '/mnt/' + m.group(0)[0].lower(), os.path.abspath(srcPath).replace("\\", "/"))
    outMntPathL = re.sub(r'^[A-Za-z]:', lambda m: '/mnt/' + m.group(0)[0].lower(), os.path.abspath(outPathL).replace("\\", "/"))
    cmd = [ "wsl", "g++", "-fPIC", "-shared", srcMntPath, "-o", outMntPathL]
    cmd.extend(flags)
    executeCmd(cmd)
    
    if(not os.path.isfile(outPathW)):
        raise Exception(f"Compilation failed: output file {outPathW} not found")
    
    if(not os.path.isfile(outPathL)):
        raise Exception(f"Compilation failed: output file {outPathL} not found")

    return {
        "windows": outPathW,
        "linux": outPathL
    }

def buildInline(fileName, code):
    full_code  = '''
#ifdef _WIN32
    #define cfunction extern "C" __declspec(dllexport)
#else
    #define cfunction extern "C"
#endif

'''
    full_code += code
    
    lines  = code.splitlines()
    functions = []
    includes = []
    includes_re = re.compile(r'#include\s*<([^>]+)>')

    for line in lines:
        line = line.strip()

        match = includes_re.match(line)
        if match:
            includes.append(match.group(1).strip())

        if line.startswith("cfunction "):
            header = line[len("cfunction "):].strip()

            otype, fnSignature = header.strip().split(" ", 1)
            fname, fparams = fnSignature.split("(", 1)
            fparams = fparams.rsplit(")", 1)[0]

            inputs = []
            if(fparams.strip() != ""):
                paramList = fparams.split(",")
                for param in paramList:
                    ptype, pname = param.rsplit(" ", 1)
                    inputs.append((ptype.strip(), pname.strip()))

            functions.append({
                "funcName": fname.strip(),
                "returnType": otype.strip(),
                "inputs": inputs,
            })

    if fileName.strip() == "" and len(functions) > 0:
        fileName = functions[0]["funcName"]
        
    return {
        "filename": fileName,
        "code": full_code,
        "includes": includes,
        "functions": functions,
    }

def scanInline(src, fpath):
    functions = []
    lines = src.splitlines()
    i = 0

    while i < len(lines):
        line = lines[i].strip()

        if line.startswith("/*[cpp]"):
            fileName = line[7:].strip()
            inline_code = ""
            i += 1
            while i < len(lines):
                line = lines[i].strip()
                if line == "*/":
                    break
                inline_code += line + "\n"
                i += 1
            
            print(f"Found inline C/C++ code block in file: {os.path.basename(fpath)}")
            functions.append(buildInline(fileName, inline_code))
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

                if('/*[cpp]' not in src):
                    continue

                funcs = scanInline(src, filePath)
                srcArr.extend(funcs)
    return srcArr

def buildExtension(srcArr, extDir):
    extYYPath = os.path.join(extDir, "inlineC.yy")
    
    srcDir = os.path.join(extDir, "src")
    if not os.path.isdir(srcDir):
        os.makedirs(srcDir)

    for root, dirs, files in os.walk(srcDir):
        for file in files:
            if file.endswith(".cpp"):
                srcCache.add(getFileHash(os.path.join(root, file)))

    files  = [];

    for src in srcArr:
        filename = src["filename"]
        code = src["code"]
        includes = src["includes"]
        functions = src["functions"]

        srcPath = os.path.join(srcDir, f"{filename}.cpp")
        with open(srcPath, 'w') as f:
            f.write(code)

        dllPath = compileFile(srcPath, extDir, includes)
        dllPathW = dllPath["windows"]
        dllPathL = dllPath["linux"]

        dllName = os.path.basename(dllPathW)
        fnEntry = ""

        for func in functions:
            func_name   = func["funcName"]
            return_type = func["returnType"]
            inputs      = func["inputs"]
            iArray = [2 if t == "double" else 1 for t, n in inputs]
            sArray = ", ".join([str(v) for v in iArray]).replace(" ", "")
            oType  = 2 if return_type == "double" else 1

            fnEntry += yycfunctionTemplate.format(
                func_name=func_name,
                iArray=f"[{sArray}]",
                iCount=len(inputs),
                oType=oType
            ) + "\n"

        files.append(yycfileTemplate.format(
            dllName=dllName,
            dllNameW=os.path.basename(dllPathW),
            dllNameL=os.path.basename(dllPathL),
            functions=fnEntry
        ))
            
    yyString = yycTemplate.format(
        files="".join(files)
    )

    with open(extYYPath, 'w') as f:
        f.write(yyString)

if __name__ == "__main__":
    scriptDir = "D:\\Project\\MakhamDev\\LTS-PixelComposer\\PixelComposer\\scripts"
    extDir = "D:\\Project\\MakhamDev\\LTS-PixelComposer\\PixelComposer\\extensions\\inlineC"

    srcArr = scanFolder(scriptDir)
    buildExtension(srcArr, extDir)