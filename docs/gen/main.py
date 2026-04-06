import os
import shutil

shutil.copytree("../content", "../pregen", dirs_exist_ok=True)

# Convert markdown to HTML
print("Runing md.py...") 
os.system("python md.py")

# Generate node files
print("Runing nodes.py...")
os.system("python node.py")

# Generate web contents
print("Runing gen.py...")
os.system("python gen.py")

# Delete pregen folder
shutil.rmtree("../pregen")