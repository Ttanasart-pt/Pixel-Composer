Sprite stack is a way to create a 3D like image using 2D images by stacking them on top of each other.

<img node_sprite_stack>

## Properties

[proptable]
Surface
Output dimension type|Method for getting output dimension.
Array Process|When inputing array of surfaces. Whether to create multiple outputs for each surface or combine all surface into one stack.
Stack
Stack Amount|Amount of layers.
Stack Shift|Shifting per layer.
Move Base|Shift the origin to the last stack layer and invert per-layer shifting.
Position|Origin position.
Rotation|Rotate surface before stacking.
Render
Stack Blend|Multiply stack by color.
Highlight|Apply different color to the layer before the last to create highlight effect.
Highlight Color|Color of the highlight layer.
Highlight Alpha|Opacity of the highlight layer.
[/proptable]

## Stacking Positions

When stacking, each copy will be shifted by the amount set by the <junc Stack shift> properties. 
The final position can also be adjusted by the <junc Position>.

The <junc Move base> property will revert the position such that the original image 
got shifted instead of the copies.

<img node_sprite_stack_position>

## Rendering Properties

<junc Stack blend> will blend the copies with a new color. You can make make the 
copies fade out over time with the <junc Alpha end> property.

<img node_sprite_stack_rendering>

The <junc Highlight> property allow you to change the color of the edge.

<img node_sprite_stack_highlight>
