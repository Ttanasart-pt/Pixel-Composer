import os

count = 0
for root, dirs, files in os.walk("docsdata/content/__nodes"):
    for file in files:
        path = os.path.join(root, file)
        with open(path, "r") as f:
            data = f.read()
        
        if data == "":
            os.remove(path)
            count += 1

print(f"Removed {count} empty files.")
        