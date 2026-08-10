import os
import re
import markdown

def parse_md(path):
    target = path.replace(".md", ".html").replace("docsdata/content", "docsdata/pregen")
    with open(path, "r") as f:
        data = f.read()

    data = data.replace("\\n\n", "<br>")

    data_html = markdown.markdown(data)
    data_html = data_html.replace("</h1>", "</h1><br>")
    data_html = data_html.replace("<h2>",  "<br><h2>", 1)
    data_html = data_html.replace("</h2>", "</h2><br>")
    data_html = data_html.replace("</h3>", "</h3><br>")
    data_html = data_html.replace("</p>",  "</p><br>" )
    data_html = data_html.replace("</ul>", "</ul><br>")

    reColorAttr = re.compile(r"\[color=(.*?)\]")

    reBanner = re.compile(r"\[banner\]([\s\S]*?)\[\/banner\]")
    banner   = reBanner.findall(data_html)
    for b in banner:
        bStrip = b.replace("<p>", "").replace("</p>", "")

        style = ""

        color = reColorAttr.findall(bStrip)
        if color:
            color = color[0]
            style = f"style='border-color: {color};background-color: {color}10;'"
            bStrip = bStrip.replace(f"[color={color}]", "")

        banner_html = f'<p class="banner" {style}>{bStrip}</p>'
        data_html   = data_html.replace(f"[banner]{b}[/banner]", banner_html)
        
    rePropTable = re.compile(r"\[proptable\]([\s\S]*?)\[\/proptable\]")
    proptable   = rePropTable.findall(data_html)
    for table in proptable:
        table_html = '<table class="prop-table cc3070">'
        rows = table.split("\n")

        for row in rows:
            if row.strip() == "":
                continue
            
            row = row.replace("<p>", "").replace("</p>", "")
            # print(f"row: {row}")

            table_html += "<tr>"
            cells = row.split("|")
            amo   = len(cells)

            if amo == 1:
                table_html += f"<td colspan='2' class='prop-section'>{cells[0].strip()}</td>"
            else:
                for i, cell in enumerate(cells):
                    cel = cell.strip()
                    if cel == "":
                        continue

                    if amo == 2 and i == 0:
                        table_html += f"<td><junc {cel}></td>"
                    else:
                        table_html += f"<td>{cel}</td>"

            table_html += "</tr>"

        table_html += "</table>"
        data_html = data_html.replace(f"[proptable]{table}[/proptable]", table_html)

    with open(target, "a") as f:
        f.write(data_html)

for root, dirs, files in os.walk("docsdata/content"):
    for file in files:
        # if file != "node_mk_tree_inline.md":
        #     continue
        if not file.endswith(".md"):
            continue

        path = os.path.join(root, file)
        parse_md(path)
