<v 1.18.0/>
This node crops the input image into smaller piece. If you want to crop image into area, you can use the <node camera> node.

## Properties

### <junc aspect ratio>
If not set to "none", the aspect ratio of the crop area will be locked to the specified value.

### <junc crop>
A vec4 value the define crop distance from the left, top, right, and bottom of the image.

### <junc fit mode>
For locked aspect ratio, this will determine how the image will be fit into the crop area.