import os
import subprocess
import re
import hashlib
import argparse

FORCE = False

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
  "copyToTargets":194,
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
  "copyToTargets":194,
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
    {{"$GMProxyFile":"","%Name":"{dllNameM}","name":"{dllNameM}","resourceType":"GMProxyFile","resourceVersion":"2.0","TargetMask":1,}},
  ],
  "resourceType":"GMExtensionFile",
  "resourceVersion":"2.0",
  "uncompress":false,
  "usesRunnerInterface":false
}},"""

yycfunctionTemplate = """{{"$GMExtensionFunction":"","%Name":"{func_name}","argCount":{iCount},"args":{iArray},"documentation":"","externalName":"{func_name}","help":"","hidden":false,"kind":1,"name":"{func_name}","resourceType":"GMExtensionFunction","resourceVersion":"2.0","returnType":{oType}}},"""

## MSVC

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
msvc_env    = None
vcpkg_root  = "D:\\lib\\vcpkg\\installed\\x64-windows"

def compile_with_msvc(src_file, out_dll):
    msvcPath = "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.44.35207\\bin\\Hostx64\\x64\\cl.exe"

    cmd = [
        msvcPath,
        '/LD',
        src_file,
        
        "/EHsc", # Enable C++ exceptions
        "/std:c++17", # Enable std::clamp and other C++17 features
                
        f'/I{vcpkg_root}\\include',
        f'/I{vcpkg_root}\\include\\freetype',

        f'/Fe:{out_dll}',

        '/link',
        f'/LIBPATH:{vcpkg_root}\\lib',
        'freetype.lib',

    ]

    # Use the captured environment
    result = subprocess.run(cmd, env={**os.environ, **msvc_env}, shell=False)

    base = os.path.splitext(out_dll)[0]
    for ext in ['.lib', '.exp']:
        try:
            os.remove(base + ext)
        except FileNotFoundError:
            pass
    
    return result.returncode == 0

## DEVICE

mac_ip = "192.168.0.99"

##

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
    outPathM = os.path.join(outDir, outName + ".dylib")

    fhash = getFileHash(srcPath)
    if fhash in srcCache:
        print(f"Skipping compilation for {outName}, no changes detected.")
        return {
            "windows": outPathW,
            "linux": outPathL,
            "mac": outPathM
        }
    
    print(f"Compiling {outName}...")

    ## Windows
    print(f"\n===== Compiling for Windows =====\n")

    global msvc_env
    if msvc_env is None:
        msvc_env = get_msvc_env(vcvars_path)

    if os.path.isfile(outPathW):
        os.remove(outPathW)

    if os.path.isfile(outPathL):
        os.remove(outPathL)

    winSucc = compile_with_msvc(srcPath, outPathW)

    if os.path.isfile(objPath):
        os.remove(objPath)

    if not winSucc:
        raise Exception(f"Compilation failed for Windows")

    if(not os.path.isfile(outPathW)):
        raise Exception(f"Compilation failed: output file {outPathW} not found")

    ## Linux (WSL)
    print(f"\n===== Compiling for Linux (WSL) =====\n")

    srcMntPath  = re.sub(r'^[A-Za-z]:', lambda m: '/mnt/' + m.group(0)[0].lower(), os.path.abspath(srcPath).replace("\\", "/"))
    outMntPathL = re.sub(r'^[A-Za-z]:', lambda m: '/mnt/' + m.group(0)[0].lower(), os.path.abspath(outPathL).replace("\\", "/"))
    
    wsl_cmd = [
        "wsl", "g++", "-fPIC", "-shared",
        srcMntPath,
        "-o", outMntPathL,
        
        # 1. Explicitly add both FreeType include directories
        "-I/usr/include/freetype2",
        "-I/usr/include",
        
        # 2. Link against FreeType library
        "-lfreetype",
        
        # 3. Static flags
        "-static-libgcc", 
        "-static-libstdc++",
    ]

    try:
        executeCmd(wsl_cmd)
    except Exception as e:
        print("Failed to compile on Linux (WSL): " + str(e))

    if(not os.path.isfile(outPathL)):
        print(f"Compilation failed: output file {outPathL} not found")

    ## MacOS ssh (don't raise exception if fail)
    print(f"\n===== Compiling for MacOS via SSH =====\n")

    try:
        scp_cmd = ["scp", srcPath, f"makhamdev@{mac_ip}:/tmp/{outName}.cpp"]
        executeCmd(scp_cmd)

        compile_cmd = (
            f"clang++ -dynamiclib -std=c++17 -target arm64-apple-macos "
            f"-I/opt/homebrew/include/freetype2 "
            f"-L/opt/homebrew/lib "
            f"-lfreetype "
            f"-o /tmp/{outName}.dylib /tmp/{outName}.cpp"
        )
        
        ssh_cmd = ["ssh", f"makhamdev@{mac_ip}", compile_cmd]
        executeCmd(ssh_cmd)

        scp_cmd = ["scp", f"makhamdev@{mac_ip}:/tmp/{outName}.dylib", outPathM]
        executeCmd(scp_cmd)
    except Exception as e:
        print("Failed to compile on MacOS: " + str(e))

    if(not os.path.isfile(outPathM)):
        print(f"Compilation failed: output file {outPathM} not found")
    
    return {
        "windows": outPathW,
        "linux": outPathL,
        "mac": outPathM
    }

def buildInlineH(fileName, code):
    return {
        "filename": fileName,
        "type": "header",
        "code": code,
        "includes": [],
        "functions": [],
    }

def buildInlineC(fileName, code):
    full_code  = '''
#ifdef _WIN32
    #define cfunction extern "C" __declspec(dllexport)
#else
    #define cfunction extern "C"
#endif

'''
    full_code += code
    
    lines     = code.splitlines()
    functions = []
    includes  = []
    libraries = []
    includes_re = re.compile(r'#include\s*<([^>]+)>')

    for line in lines:
        line = line.strip()

        match = includes_re.match(line)
        if match:
            includes.append(match.group(1).strip())

        if line.startswith("//lib"):
            lib_name = line[len("//lib"):].strip()
            if lib_name:
                libraries.append(lib_name)

        if line.startswith("cfunction "):
            header = line[len("cfunction "):].strip()

            otype, fnSignature = header.strip().split(" ", 1)
            fname, fparams = fnSignature.split("(", 1)
            fparams = fparams.rsplit(")")[0].strip()

            # print(f"Parsing function: |{fname.strip()}| with return type |{otype.strip()}| parameters |{fparams}|")
            inputs = []
            if(fparams != ""):
                paramList = fparams.split(",")
                for param in paramList:
                    ptype, pname = param.rsplit(" ", 1)

                    # print(f"Parsing parameter: |{ptype}|{pname}|")
                    inputs.append((ptype.strip(), pname.strip()))

            functions.append({
                "funcName": fname.strip(),
                "returnType": otype.strip(),
                "inputs": inputs,
            })

    if fileName == "":
        if len(functions) == 0:
            return None
        else: 
            fileName = functions[0]["funcName"]

    return {
        "filename": fileName,
        "type": "code",
        "code": full_code,
        "includes": includes,
        "functions": functions,
        "libraries": libraries,
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
            
            if fileName.endswith(".h"):
                print(f"Found inline C/C++ header block in file: {os.path.basename(fpath)}")
                fn = buildInlineH(fileName, inline_code)
                if fn is not None:
                    functions.append(fn)
            else:
                print(f"Found inline C/C++ code block in file: {os.path.basename(fpath)}")
                fn = buildInlineC(fileName, inline_code)
                if fn is not None:
                    functions.append(fn)
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
        filename  = src["filename"]
        ftype     = src["type"]
        code      = src["code"]
        includes  = src["includes"]
        functions = src["functions"]
        libraries = src["libraries"] if "libraries" in src else []

        if ftype == "header":
            scrPath = os.path.join(srcDir, filename)
            with open(scrPath, 'w') as f:
                f.write(code)
            continue

        srcPath = os.path.join(srcDir, f"{filename}.cpp")
        with open(srcPath, 'w') as f:
            f.write(code)

        dllPath = compileFile(srcPath, extDir, includes)
        dllPathW = dllPath["windows"]
        dllPathL = dllPath["linux"]
        dllPathM = dllPath["mac"]

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

        for lib in libraries:
            print(f"Adding library: {lib}")
            files.append(yycfileTemplate.format(
                dllName=lib,
                dllNameW=lib,
                dllNameL=lib,
                dllNameM=lib,
                functions=""
            ))

        files.append(yycfileTemplate.format(
            dllName=dllName,
            dllNameW=os.path.basename(dllPathW),
            dllNameL=os.path.basename(dllPathL),
            dllNameM=os.path.basename(dllPathM),
            functions=fnEntry
        ))
            
    yyString = yycTemplate.format(
        files="".join(files)
    )

    with open(extYYPath, 'w') as f:
        f.write(yyString)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true")

    scriptDir = "D:\\Project\\MakhamDev\\LTS-PixelComposer\\PixelComposer\\scripts"
    extDir = "D:\\Project\\MakhamDev\\LTS-PixelComposer\\PixelComposer\\extensions\\inlineC"

    args = parser.parse_args()
    if args.force:
        FORCE = True

    srcArr = scanFolder(scriptDir)
    buildExtension(srcArr, extDir)

    print("Compile completed.")