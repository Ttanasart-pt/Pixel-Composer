import os

for root, dirs, files in os.walk("docsdata/content/__nodes"):
    for file in files:
        # if file.endswith(".md"):
        #     continue

        path = os.path.join(root, file)
        with open(path, "r") as f:
            data = f.read()

        data = data.replace("<p>",  "")
        data = data.replace("</p>", "")

        data = data.replace("<h1>",  "# ")
        data = data.replace("</h1>", "")
        data = data.replace("<h2>",  "## ")
        data = data.replace("</h2>", "")
        data = data.replace("<h3>",  "### ")
        data = data.replace("</h3>", "")

        data = data.replace("<br>", "\n")

        npath = os.path.splitext(path)[0] + ".md"
        os.remove(path)
        with open(npath, "w") as f:
            f.write(data)
