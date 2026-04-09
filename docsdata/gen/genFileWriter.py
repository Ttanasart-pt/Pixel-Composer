# %%
import os
import re

import fileUtil
from fileUtil import FileType, pathRemoveOrder

# %%
svg_home = fileUtil.readFile("docs/src/svg/home.svg")
svg_dir  = fileUtil.readFile("docs/src/svg/dir.svg")

images = {}
for root, dirs, files in os.walk("docs/src"):
    for file in files:
        if not file.endswith(".png"):
            continue
        
        if root.find("__") != -1:
            continue

        key = file[:-4].lower()
        images[key] = os.path.join(root.replace("docs/", ""), file).replace("\\", "/")

template = fileUtil.readFile("docsdata/templates/page.html")

#%%
def generateFile(dirOut, pathIn):
    with open(pathIn, "r") as f:
        content = f.read()

    pathIn    = pathRemoveOrder(pathIn)
    fileName  = os.path.basename(pathIn)
    pathOut   = f"{dirOut}/{fileName}"
    headers   = []
    badges    = ""

    version = re.findall(r"<v (.*?)>", content)
    if len(version) > 0:
        version = version[0]
        content = content.replace(f"<v {version}>", "")

        version = version.strip("/").strip()
        badges += f'<p class="version-banner" title="This page is updated on version {version}">{version}</p>'
    else:
        badges += f'<p class="version-banner" title="This page is written before 1.18, some information might be outdated">pre 1.18</p>'

    h1s = re.findall(r"<h1>(.*?)</h1>", content)
    if len(h1s) > 0:
        h1 = h1s[0]
        content = content.replace(f"<h1>{h1}</h1>", f'''<div class="title">
                                                            <h1>{h1}</h1>
                                                            <div class="badges">{badges}</div>
                                                        </div>''')
        
    
    for h2s in content.split("<h2>")[1:]:
        h2      = re.findall(r"(.*?)</h2>", h2s)[0]
        h2text  = re.sub(r'<.*?>', '', h2)
        content = content.replace(f"<h2>{h2}</h2>", f'<h2><a id="{h2text}" class="anchor"></a>{h2}</h2>')
        
        h3s = re.findall(r"<h3>(.*?)</h3>", h2s)
        for i, _h3 in enumerate(h3s):
            h3 = re.sub(r'<(.*?)\/.*?>', '', _h3)
            if h3 == "":
                h3 = re.sub(r'<.*?>', '', _h3)
            h3s[i] = h3
            content = content.replace(f"<h3>{_h3}</h3>", f'<h3><a id="{h3}" class="anchor"></a>{_h3}</h3>')

        headers.append({"h2": h2, "h3s": h3s})

    imgs = re.findall(r"<img (.*?)>", content)
    for img in imgs:
        imgraw = img.strip("/")

        quiet = re.search(r'quiet', img)
        if quiet:
            imgraw = imgraw.replace("quiet", "").strip()

        if imgraw.lower() in images:
            content = content.replace(f"<img {img}>", f'<img class="node-content" src="/{images[imgraw.lower()]}">')
            
        elif "=" not in imgraw and not quiet: 
            print(f"{pathOut} : Image {imgraw} not found")

    imgs = re.findall(r"<img-deco (.*?)>", content)
    for img in imgs:
        originalText = f"<img-deco {img}>"
        
        caption = re.search(r'caption=\"(.*?)\"', img)
        captionText = None
        if caption:
            captionText = caption.group(1)
            img = img.replace(f'caption="{captionText}"', "").strip()
        imgraw = img.strip("/")

        quiet = re.search(r'quiet', img)
        if quiet:
            imgraw = imgraw.replace("quiet", "").strip()

        if imgraw.lower() in images:
            replaceText  = ""

            if captionText == None:
                replaceText += f'<img class="node-content deco" src="/{images[imgraw.lower()]}">'
            else:
                replaceText += "<figure>"
                replaceText += f'<img class="node-content deco" src="/{images[imgraw.lower()]}">'
                replaceText += f"<figcaption>{captionText}</figcaption>"
                replaceText += "</figure>"
            content = content.replace(originalText, replaceText)

        elif "=" not in imgraw and not quiet: 
            print(f"{pathOut} : Image {imgraw} not found")

    nodeTags = re.findall(r'<node\s(.*?)>', content)
    for tag in nodeTags:
        name = tag.strip("/")
        content = content.replace(f'<node {tag}>', f'<a class="node" href="/nodes/_index/{name}.html">{name.title()}</a>')

    data = template.replace("{{content}}", content)

    
    breadcrumbs  = f'''<div class="breadcrumb">'''
    pathOutSplit = pathOut.replace("\\", "/").split("/")
    if pathOutSplit[-1] == "index.html":
        pathOutSplit = pathOutSplit[:-1]
        
    for i in range(1, len(pathOutSplit)):
        pathPart = pathOutSplit[i].replace(".html", "")
        if pathPart == "_index":
            continue
        
        breadcrumbPath = "/" + "/".join(pathOutSplit[1:i+1])
        breadTitle     = pathPart.title().replace("_", " ")
        breadcrumbs   += f'<a href="{breadcrumbPath}">{breadTitle}</a>'
        if i != len(pathOutSplit) - 1:
            breadcrumbs += '<div class="breadcrumb-separator"></div>'
    breadcrumbs += "</div>"
    data = data.replace("{{breadcrumbs}}", breadcrumbs)

    with open(pathOut, "w") as f:
        f.write(data)

    title = fileName.replace('.html', '').replace('_', ' ').title()
    return (title, pathOut)