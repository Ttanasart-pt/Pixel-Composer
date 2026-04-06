<v 1.18.1/>
Convert image array, or animation to sprite sheet.

## Properties

### <junc sprites>
Input image(s) or animation.

### <junc sprite set>
Whether to convert image array or animation to sprite sheet.

For animation type, the project need to be played from start to finish to generate the sprite sheet.

### <junc frame step>
Number of frame to progress per sprite sheet frame (set to 1 will render every frame, 2 will render one image per 2 frames, etc.)

### <junc packing type>
How to pack the sprite sheet.

### <junc alignment>
For `horizontal` and `vertical` packing type, how to align the images in the axis (if the source image have different sizes).

### <junc spacing>
Spacing between each images in the sprite sheet.

### <junc padding>
Apply extra space around the entire sprite sheet.

### <junc custom range>
Set custom range of images to convert to sprite sheet, whether the animation range or array index range.