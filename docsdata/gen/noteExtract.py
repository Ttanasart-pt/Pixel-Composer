import os
import shutil

for scrDir in os.listdir("scripts/"):
    if scrDir.startswith("node_"):
        noteName = scrDir.replace("node_", "note_")
        noteDir  = os.path.join("notes/", noteName)
        if not os.path.exists(noteDir):
            continue

        notePath = os.path.join(noteDir, f"{noteName}.txt")
        if not os.path.exists(notePath):
            continue

        with open(notePath, 'r') as f:
            noteContent = f.read()
        
        basePath = os.path.join("docsdata/content/__nodes/", scrDir)
        with open(basePath + ".md", 'w') as f:
            f.write(noteContent)