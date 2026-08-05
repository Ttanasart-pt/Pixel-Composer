Darken pixels from the nearest edge. Work best with black and white image. The height of the bevel is based on the brightness of that pixel.

<img node_bevel>

## Properties

[proptable]
Bevel
Slope|Shape of the bevel profile.
Height|Maximum bevel level.
Highres|Use shader with higher iteration for cleaner output.

Transform
Shift|Move bevel per level.
Scale|Scale distance per each bevel level.
[/proptable]

## Transformation

<junc Shift> and <junc Scale> are used to create directional shading effect. Reducing the scale to be lower than 1 increase the width of 
each band. Then apply shift to set light position.

<img node_bevel_transform>