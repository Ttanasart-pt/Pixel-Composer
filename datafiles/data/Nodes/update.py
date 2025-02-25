import os

DIR = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datafiles/data/Nodes"

ltime = 0
lpath = f"{DIR}/latest_zip_time.txt"
if os.path.exists(lpath):
    with open(lpath, 'r') as f:
        ltime = f.read() 
        ltime = float(ltime)

root = f"{DIR}/Internal"
etime = max(os.path.getmtime(r) for r,_,_ in os.walk(root))

if etime > ltime:
    print("Update node zip...")

    ps = "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
    os.system(f'{ps} "{DIR}/Update.ps1"')

    with open(lpath, 'w') as f:
        f.write(str(etime))

else :
    print("Node up to date")