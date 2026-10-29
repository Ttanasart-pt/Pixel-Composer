import os
import re
import shutil
import fileUtil
import json5 as json
from tqdm import tqdm

src_dir = "docsdata/examples"
dst_dir = "docsdata/pregen/3_nodes/_examples"

shutil.copytree(src_dir, "docs/examples", dirs_exist_ok=True)
fileUtil.verifyFolder(dst_dir)

if not os.path.exists(src_dir):
    exit()

nodes = os.listdir(src_dir)
for node in tqdm(nodes, desc="Node examples"):
    src_node_dir = os.path.join(src_dir, node)
    dst_path = os.path.join(dst_dir, f"{node}.html")

    examples = os.listdir(src_node_dir)

    page = ""
    page += f"<h2>Usage Examples: {node}</h2><br>"
    page += f"<p>{len(examples)} example(s) found.</p><br>"
    page += '<table class="usage-table">\n'
    page += '<tr><th>Preview</th><th>Inputs</th><th>Project</th></tr>\n'

    for example in examples:
        example_path = os.path.join(src_node_dir, example)

        _data = os.path.join(example_path, "data.json")
        _prev = os.path.join(example_path, "preview.png")
        _dir  = f'/examples/{node}/{example}'

        page += "<tr>\n"
        if os.path.exists(_prev):
            page += f"<td class='preview'><img src='{_dir}/preview.png'></td>\n"

        if os.path.exists(_data):
            with open(_data, "r", encoding="utf-8") as df:
                data = json.load(df)

            data_inputs  = data["inputs"]
            data_project = data["project"]
            data_url     = data["url"]

            input_list = "";
            for inp in data_inputs:
                if isinstance(inp, str):
                    input_list += f"<img src='{_dir}/{inp}.png' alt='{inp}' loading='lazy'>"
                
            page += f"<td class='inputs'>{input_list}</td>\n"

            page += f"<td class='data'><p>{data_project}</p><a href='{data_url}'>{data_url}</a></td>\n"

        page += "</tr>\n"

    page += "</table>\n"

    with open(dst_path, "w", encoding="utf-8") as f:
        f.write(page)
    


