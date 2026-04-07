import os

for root, dirs, files in os.walk("docsdata/content/__nodes"):
    for file in files:
        newname = file.replace(".txt", ".md")
        os.rename(os.path.join(root, file), os.path.join(root, newname))
