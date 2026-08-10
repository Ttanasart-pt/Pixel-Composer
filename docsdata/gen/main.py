import os
import shutil
import time
import subprocess

starttime = time.time()

if os.path.exists("docsdata/pregen"):
    shutil.rmtree("docsdata/pregen")
shutil.copytree("docsdata/content", "docsdata/pregen", dirs_exist_ok=True)

# Extract note from the source code
print("> Running note_extract.py...") 
# os.system("python docsdata/gen/noteExtract.py")
subprocess.run(["python", "docsdata/gen/noteExtract.py"])

# Convert markdown to HTML
print("> Running md.py...") 
# os.system("python docsdata/gen/md.py")
subprocess.run(["python", "docsdata/gen/md.py"])

# Generate node files
print("> Running nodes.py...")
# os.system("python docsdata/gen/node.py")
subprocess.run(["python", "docsdata/gen/node.py"])

# Generate web contents
print("> Running gen.py...")
# os.system("python docsdata/gen/gen.py")
subprocess.run(["python", "docsdata/gen/gen.py"])

# Delete pregen folder
# shutil.rmtree("docsdata/pregen")
endtime = time.time()
print(f"> Generating docs complete in {endtime - starttime:.2f} s")

# Commit and push to GitHub
print("> Committing and pushing to GitHub...")
# os.system("git add .")
# os.system('git commit -m "Update docs"')
# os.system("git push")
subprocess.run(["git", "add", "."])
subprocess.run(["git", "commit", "-m", "Update docs"])
subprocess.run(["git", "push"])