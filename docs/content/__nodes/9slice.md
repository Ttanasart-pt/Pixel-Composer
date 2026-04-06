<v 1.18.0/>
Create a 9-slice image from a source image. 9-slice images are used to create scalable images that can be stretched without distorting the corners. This is useful for creating scalable buttons, panels, and other UI elements.

## Properties

### <junc surface in>
Input image to create 9-slice from.

### <junc dimension>
Output image size.

### <junc splice>
4 values that define the 9-slice regions. The values are in the order of left, top, right, bottom.

### <junc filling modes>
Whether to stretch (scale) or repeat the 9-slice regions.