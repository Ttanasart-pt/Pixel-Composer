This node allow you to read the content of a aseprite file (.ase, .aseprite). It supports layers, tags, palette (index mode). It does not support tilemap.

## Properties

[proptable]
Path|Path to the aseprite file.

Layers
Generate Layers|Generate <node ase_layer> nodes for each layer for further processing.
Use cel Dimension|By default, each layer will be cropped to fit the content. Uncheck this option will force all layer to use the canvas dimension.

Tags
Current Tag|The tag to read (if exists).
[/proptable]
