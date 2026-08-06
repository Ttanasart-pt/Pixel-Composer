import os
import re
import markdown

def parse_md(path):
    target = path.replace(".md", ".html").replace("docsdata/content", "docsdata/pregen")
    with open(path, "r") as f:
        data = f.read()

    data_html = markdown.markdown(data)
    data_html = data_html.replace("</h1>", "</h1><br>")
    data_html = data_html.replace("<h2>",  "<br><h2>", 1)
    data_html = data_html.replace("</h2>", "</h2><br>")
    data_html = data_html.replace("</h3>", "</h3><br>")
    data_html = data_html.replace("</p>",  "</p><br>" )
    data_html = data_html.replace("</ul>", "</ul><br>")

    reProp = re.compile(r"\[proptable\]([\s\S]*?)\[\/proptable\]")
    proptable = reProp.findall(data_html)
    for table in proptable:
        table_html = '<table class="cc3070">'
        rows = table.split("\n")
        for row in rows:
            if row.strip() == "":
                continue

            table_html += "<tr>"
            cells = row.split("|")
            amo   = len(cells)

            if amo == 1:
                table_html += f"<th colspan='2' class='header'><junc {cells[0].strip()}></th>"
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
        path = os.path.join(root, file)
        if file.endswith(".md"):
            parse_md(path)