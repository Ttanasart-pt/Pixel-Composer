import os
import re
import sys

CONFIG_DIR = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/options/"
GLOBAL_DATA_PATH = r"D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/scripts/globals/globals.gml"

os_targets = ["windows", "linux", "mac"]

def main():
    re_version = re.compile(r'VERSION_STRING\s*=\s*"([^"]+)"')
    with open(GLOBAL_DATA_PATH, 'r') as f:
        content = f.read()
        match = re_version.search(content)
        if match:
            version_string = match.group(1)
            print(f"================ Update version string : {version_string} ================")
        else:
            print("Error: VERSION_STRING not found in globals.gml")
            sys.exit(1)

    display_name = f"Pixel Composer {version_string}"
    version = version_string
    
    for target in os_targets:
        config_file = f"{CONFIG_DIR}{target}/options_{target}.yy"
        if not os.path.exists(config_file):
            print(f"Error: Configuration file for {target} not found at {config_file}")
            continue

        re_disp_name = re.compile(f"\"option_{target}_display_name\":\"(.*?)\"")
        re_version   = re.compile(f"\"option_{target}_version\":\"(.*?)\"")

        with open(config_file, 'r') as f:
            content = f.read()

            if not re_disp_name.search(content):
                print(f"Error: Display name pattern not found in {config_file}")
            if not re_version.search(content):
                print(f"Error: Version pattern not found in {config_file}")

            content = re_disp_name.sub(f"\"option_{target}_display_name\":\"{display_name}\"", content)
            content = re_version.sub(f"\"option_{target}_version\":\"{version}\"", content)

            with open(config_file, 'w') as f:
                f.write(content)
                print(f" ✓ Updated {target} configuration complete.")

    print("\n")

if __name__ == "__main__":
    main()