import os
import re
import markdown

def parse_md(path):
    target = path.replace(".md", ".html").replace("../content", "../pregen")
    with open(path, "r") as f:
        data = f.read()

    data_html = markdown.markdown(data)
    data_html = data_html.replace("</h1>", "</h1><br>")
    data_html = data_html.replace("<h2>",  "<br><h2>", 1)
    data_html = data_html.replace("</h2>", "</h2><br>")
    data_html = data_html.replace("</h3>", "</h3><br>")
    data_html = data_html.replace("</p>",  "</p><br>" )
    data_html = data_html.replace("</ul>", "</ul><br>")
    
    with open(target, "a") as f:
        f.write(data_html)

for root, dirs, files in os.walk("../content"):
    for file in files:
        path = os.path.join(root, file)
        if file.endswith(".md"):
            parse_md(path)