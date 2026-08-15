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
    data_html = data_html.replace("</table>", "</table><br>")

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

            cells = row.split("|")
            amo   = len(cells)

            if amo == 1:
                table_html += "<tr class='prop-section-row'>"
                table_html += f"<td colspan='2' class='prop-section'>{cells[0].strip()}</td>"
            else:
                table_html += "<tr>"
                for i, cell in enumerate(cells):
                    cel = cell.strip()
                    if cel == "":
                        continue

                    if amo == 2 and i == 0:
                        table_html += f"<td><junc {cel}></td>"
                    else:
                        table_html += f"<td>{cel}</td>"

            table_html += "</tr>"

        table_html += "</table><br>"
        data_html = data_html.replace(f"[proptable]{table}[/proptable]", table_html)

    reTable = re.compile(r"\[table\]([\s\S]*?)\[\/table\]")
    tables  = reTable.findall(data_html)
    for table in tables:
        table_html = '<table class="cc3070">'
        rows = table.split("\n")

        for row in rows:
            if row.strip() == "":
                continue
            
            row = row.replace("<p>", "").replace("</p>", "")

            cells = row.split("|")
            amo   = len(cells)

            table_html += "<tr>"
            for i, cell in enumerate(cells):
                cel = cell.strip()
                if cel == "":
                    continue
                table_html += f"<td>{cel}</td>"

            table_html += "</tr>"

        table_html += "</table><br>"
        data_html = data_html.replace(f"[table]{table}[/table]", table_html)

    # make sure that there're 2 <br> before h2
    reH2 = re.compile(r"(?:<br>)*<h2")
    data_html = reH2.sub("<br><h2", data_html)

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
