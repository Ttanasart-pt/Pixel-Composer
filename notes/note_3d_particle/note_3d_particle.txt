Simulate particle in 3D space.

## Properties

[proptable]
Object
Mesh|Particle Model

/Spawn
Spawn Type|Whether to spawn every frame (**Stream**), once at a set frame (**Burst**), or with trigger (**Trigger**).
Lifespan|Particle lifespan

/Source
Spawn Source|Type or shape to spawn particle from.\n\t**Shape**: Spawn from fixed 3D shape.\n\t**Path**: Spawn from path data.\n\t**Mesh Vertices**: Spawn from any 3D mesh verticies.\n\t**Direct Data**: Spawn from array of Vec3 points.

Movement
Velocity|Initial velocity.
Acceleration|Change of velocity per frame.
Follow Spawn Shape|In **Shape** Spawn Source, add velocity from the shape to particle.

Rotation
Rotation|Initial rotation.
Rotational Speed|Change in rotation per frame.
Snap Rotation|Snap rotation angle (in degree) before render.
Follow Velocity|Rotate the particle model to follow its current velocity.

Scale
Scale|Particle scale in XYZ axes.
Size|Uniform scaling.

Color
Color Over Lifetime|Particle blend over lifespan (multiply with base material).
Random Blend|Random initial color per particle.
Alpha|Particle opacity.

Render
Blend Mode|Rendering blend mode.
Billboard|Rotate particle to always face the camera.
Loop|Pre-render the particle before the first frame to create loopable animation.
Pre-Render|Amount of frame to pre-render if <junc Loop> is set to true.

Path
Path|Move the particles along custom path.
Path Deviation|The number to multiply particle absolute position to add to the path position to create the final position.

Physics
Gravity|Add gravity to particle.
Turning|Add random turning force to each particles.
Turn Both Directions|Apply randomized 1, -1 multiplier to the turning speed.
Turn Scale with Speed|Scale turning force with particle speed.

Ground
Ground|Add +Z ground collision to the particle.
Ground Offset Type|Make the ground an **Absolute** global position or **Relative** to particle spawning position.
Ground Offset|Ground position in **Absolute** type, or offset from the spawn point in **Relative** mode.
Bounce Amount|Apply bounce on collision with the ground.
Bounce Friction|Reduce velocity in other axis when collide with the ground.

Wiggles
Direction Wiggle|Apply random direction while keeping current velocity.
Position Wiggle|Apply random positional shifting.
Rotation Wiggle|Apply random rotation.
Scale Wiggle|Apply random scale.
[/proptable]