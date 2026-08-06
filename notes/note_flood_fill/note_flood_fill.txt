Flood fill node fill a region with the same color with a new color. That region is based on a single points. If you want to map all regions with new colors, you can use <node region_fill> node.
<img-deco flood_fill/>

## Properties

[proptable]
Fill
Fill Mode|Type of fill source.
Position|Position of a pixel in the region to fill.
Threshold|How different a color to be to be consider the same region.

Algorithm
Algorithm|Flood fill algorithm.
Diagonal|Whether to fill diagonal pixel.
Iteration|Maximum fill iteration.

Rendering
Colors|Color to fill to.
Blend|Blending mode between the original and the filled color.

Background
Fill Background|Whether to fill background with solid color.

Gradient
Fill Gradient|Use different color (sampled from a gradient) per each iteration.
[/proptable]