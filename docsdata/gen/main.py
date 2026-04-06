import os
import shutil
import time

starttime = time.time()
shutil.copytree("docsdata/content", "docsdata/pregen", dirs_exist_ok=True)

# Extract note file from the source code
print("> Runing note_extract.py...") 
os.system("python docsdata/gen/noteExtract.py")

# Convert markdown to HTML
print("> Runing md.py...") 
os.system("python docsdata/gen/md.py")

# Generate node files
print("> Runing nodes.py...")
os.system("python docsdata/gen/node.py")

# Generate web contents
print("> Runing gen.py...")
os.system("python docsdata/gen/gen.py")

# Delete pregen folder
shutil.rmtree("docsdata/pregen")
endtime = time.time()
print(f"> Generating docs complete in {endtime - starttime:.2f} s")