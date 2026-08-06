Repeat surface over a fix pattern. To scatter surface randomly, use <node Node_Scatter> node.

## Properties

[proptable]
Surfaces
Output Dimension Type|Method for determining output dimension.
Array Select|Whether to select image from an array in order, at random, or spread each image to its own output.

Pattern
Pattern|Repeation pattern.
Global Anchor|Repositon all repeated image After it's repeation.
Global Rotation|Rotate all repeated surface around one global anchor.

Path
Path|Make repeated surface follows path. Set <junc Shift Position> to [0,0] to remove offset.
Path Range|Range of the path to distribute.
Path Shift|Shift position along path.
Rotate Along Path|Whether to rotate object along path normal.

Position
Shift Position|Move surface by a fix amount per copies.
Stack|Automatically shift the next copy by the width of the current one. Set <junc Shift Position> to [0,0] to remove offset.
Shift Column|Move surface by a fix amount per row (in grid mode).
Anchor|Draw anchor.
Random Position|Add random shifting.
Use Shift as Endpoint|Instead of shifting each copy by a fix amount. The <junc Shift Position> determine where the last copy would be and subdivided other copies in-between.

Rotation
Base Rotation|Rotation of the first copy.
Repeat Rotation|Adjust rotation of subsequence copy by a fix amount.
Random Rotation|Add random rotation to each copy.

Scale
Uniform Scale|Force the final scale to have the same X and Y scale factor.
Random Scale|Add random scale to each copy.

Render
Blend Mode|Drawing blend mode.
Sort Y|Sort drawing order by it's Y position to create top-down depth effect.
[/proptable]
