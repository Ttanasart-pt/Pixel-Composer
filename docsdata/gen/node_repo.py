import os
import re
import shutil
import fileUtil
import json5 as json
from tqdm import tqdm

src_dir = "docsdata/node_usage_repo"
dst_dir = "docsdata/pregen/3_nodes/_nodeUsage"

shutil.copytree(src_dir, "docs/node_usage_repo", dirs_exist_ok=True)
fileUtil.verifyFolder(dst_dir)

if not os.path.exists(src_dir):
    exit()

nodes = os.listdir(src_dir)
for node in tqdm(nodes):
    src_node_dir = os.path.join(src_dir, node)
    dst_path = os.path.join(dst_dir, f"{node}.html")
    page = "<table>\n"

    examples = os.listdir(src_node_dir)
    for example in examples:
        example_path = os.path.join(src_node_dir, example)

        _data = os.path.join(example_path, "data.json")
        _prev = os.path.join(example_path, "preview.png")

        page += "<tr>\n"
        if os.path.exists(_prev):
            page += f"<td><img src='/node_usage_repo/{node}/{example}/preview.png'></td>\n"
        if os.path.exists(_data):
            with open(_data, "r", encoding="utf-8") as df:
                data = json.load(df)

            data_project = data["project"]
            data_url = data["url"]

            page += f"<td><a href='{data_url}'>{data_project}</a></td>\n"
        page += "</tr>\n"

    page += "</table>\n"

    with open(dst_path, "w", encoding="utf-8") as f:
        f.write(page)
    


