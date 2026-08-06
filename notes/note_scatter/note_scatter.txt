Scatter surface randomly. To repeat surface in fixed pattern use <node Node_Repeat> node.

## Properties

[proptable]
Surfaces
Array|Choose surface array processing method:\n
 - Spread Output: Create multiple surfaces for each surface separately.\n
 - Index: Mix all input surfaces using spawn index as array index.\n
 - Random: Mix all input surfaces with random array index.\n
 - Data: Using third value (if exists) to determine array index.\n
 - Texture: Use external surface to select array index.
Animated|With surface array connected, increase array index per frame.
Animated End|Select what to do when index outside array range.

Scatter > Source
Source|Scatter area type.
Extra Value|In point array source, apply the third and later values in each data point (if exist) to the given properties.
Distribution|Scatter distribution.

Amount
Amount|Scatter amount.
Distance|In poisson distribution, set minimum distance between each copies.
Attempt|In map distribution, set sampling attempt before gives up.

Path
Path|Scatter along path.
Rotate Along Path|Make the copy rotate along path normal.
Path Range|Range of the path to follow.
Path Shift|Shift position along path.
Scatter Distance|Set random shift distance away from the path.

Position
Random Position|Randomly move surface from it's original place.
Shift Position|Move surface with fixed amount increase per copy.
Shift Radial|Move surface based on its rotation.
Exact|Round drawing position to integer.

Rotation
Rotation|Base angle.
Point at Center|Rotate each copy to face the spawn center.
Random Angle|Rotate surface randomly.

Scale
Scale|Base scale.
Offset Scale|Scale surface randomly in both axis independenly.
Scale Random|Scale surface randomly in both axis uniformly.
Uniform Scaling|Force the final scaling to have the same value in X and Y axis.

Color
Random Blend|Apply random color blending per copy.
Alpha|Apply random opacity per copy.
Multiply Alpha|Multiply opacity to RGB channel before drawing.

Sample Color
Sample Surface|Blend surface based on color sampled from additional surface.
Sample Wiggle|Randomly modify sample point.

Rendering
Blend Mode|Drawing blend mode.
Sort Y|Sort drawing order by it's Y position to create top-down depth effect.
Tile|Draw overflow surface to the other side of the surface to create tiling effect.
[/proptable]
