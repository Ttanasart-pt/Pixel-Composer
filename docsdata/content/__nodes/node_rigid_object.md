Create new Rigidbody object.

## Properties

[proptable]
Spawn
Spawn|Make object spawn when start.
Spawn Frame|Frame to spawn if <junc Spawn> is off.
Spawn Position|Initial position.
Spawn Rotation|Initial angle.

Velocity
Initial Velocity|Apply velocity on start.

Shape
Shape|Collision shape.
Add Pixel for Empty|In custom mesh mode, whether to add 1x1 pixel for empty surface.

Physics
Collision Group|Mark object to only collide object of the same group.
Affect by Force|Whether to have object affected by force (gravity, collsion) or static (for floor, wall).
Mass|Object mass.
Air Resistance|Slow object when falling.
Rotation Resistance|Add force for rotating object.
Gravity Scale|Set custom gravity effect.

Simulation
Continuous|Calculate collision continuously. Can be used to prevent fast moving small object from clipping thorugh thin wall. 
Fix Rotation|Force object to not rotate.
Sleepable|Allow object to stop receiving collision when stop.
Activate on Spawn|Activate object physics on spawn.
[/proptable]
