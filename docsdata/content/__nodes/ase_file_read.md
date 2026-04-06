<v 1.18.0/>
This node allow you to read the content of a aseprite file. It supports layers, tags, palette (index mode). It does not support tilemap.

## Properties

### <junc path>
Path to the aseprite file.

### <junc generate layers>
Generate <node ase_layers> nodes for each layer for further processing.

### <junc use cel dimension>
By default, each layer will be cropped to fit the content. Uncheck this option will force all layer to use the canvas dimension.

### <junc current tag>
The tag to read (if exists).