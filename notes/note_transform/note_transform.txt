Transform a surface.

## Properties

[proptable]
Output
Output Dimension Type|Methods for calculating output.\n
 - **Same as Input**: Use the same dimension as input.\n
 - **Constant**: Set constant pixel dimension.\n
 - **Relative to Input**: Set as multiple of the input dimension.\n
 - **Fit Content**: Sized to fit transformed surface.
Render Mode|Whether to add tiling or wrap the content.

Position
Round Position|Round position to the nearest integer value to avoid anti-aliasing.

Rotation
Relative Anchor|Set the <junc Anchor> relative to the surface or in world space.
Rotate by Velocity|Make the surface rotates to follow its movement set by <junc Position>.

Path
Path|Move surface along path.
Position|Relative position on the path.
Rotate Along|Make the surface rotate along the path.

Stretch
Stretch|Scale surface in the direction of its movement.
Stretch Intensity|Scaling amount per speed.
Inv Stretch|Apply inverse scaling on the perpendicular axis to simulate volume preservation effect.

Echo
Echo|Draw multiple copies of the surface interpolating motion between frames.
Echo Type|Echo type.\n
 - **Static**: Echo from the origin transformation to the current transform.\n
 - **Animated**: Echo between frames.
Echo Amount|Amount of copies to draw.
[/proptable]
