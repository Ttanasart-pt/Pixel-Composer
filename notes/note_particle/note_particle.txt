[banner]
Associated tutorial: **Particles**
[/banner]

Simulate 2D particle effect.

## Properties

[proptable]
Sprite
Surface Array|Method of procesing surface array:\n
 - **Random**: Set random surface for each particle.\n
 - **Order**: Set surface in order of the particle spawning.\n
 - **Animation**: Use surface array as animation. Particle spawn with the first surface in the array then increase the index over lifespan.\n
 - **Scale**: Select array index based on particle scale.
Animation Speed|For animation type, define surface array animating speed (array index per frame of lifespan.)
Stretch Animation|For animation type, whether to stretch animation to particle lifespan.
On Animation End|For animation type, choose what to do when animation reach an end.

Spawn
Spawn Type|Spawn Timing\n
 - **Stream**: Spawn particles constantly.\n
 - **Burst**: Spawn particles once in burst.\n
 - **Trigger**: Spawn particles using manual trigger.
Spawn Delay|For Stream type, frames delay between each particle spawn.
Spawn Frame|For Burst type, frame index to spawn.
Burst Duration|For Burst type, amount of frames to spawn.
Spawn Amount|Amount of particles to spawn per frame.

Spawn > Lifespan
Lifespan|Particle lifespan.

Spawn > Source
Spawn Source|Type of particle spawn source.\n
 - **Area Inside**: Spawn inside an area.\n
 - **Area Border**: Spawn around area border.\n
 - **Map**: Spawn based on greyscale surface.\n
 - **Path**: Spawn along a path.\n
 - **Direct Data**: Spawn from array of vec2 points.
Distribution|For area, path source, particle spawning pattern.
Uniform Period|For uniform distribution, define distribution amount (e.g. if set to 4, particle will spawn at 4 fixed points in the source.)\n
If set to zero, will use <junc Spawn Amount>.

Movement
Speed|Particle initial speed. If use speed over lifespan curve it may causes conflict with physics.

Movement > Direction
Initial Direction|Initial direction range.
Directed From Center|Make particle move away from the spawn center.
Angle Range|For Directed From Center, define range of angle around the center.

Movement > Wrap
Wrap|Loop particle from one side of the surface to another.

Rotation
Rotate by Direction|Make the particle rotates to follow its movement. This value will be offset by <junc Initial Rotation>.

Rotation > Animated
Rotation Type|Type of rotation animation.\n
 - **Speed**: Add rotation angle per frame.\n
 - **Fix Relative**: Lerp to angle ralative to orignal angle over lifespan.\n
 - **Fix target**: Lerp to fix angle over lifespan.
Snap|Snap rotation to fixed angle.

Scale
Scale|Define non-uniform particle scale.
Size|Uniform particle scale.

Color
Color on Spawn|Initial particle color.
Color by Index|Particle color per spawn index.
Color over Lifetime|Apply color over lifespan.

Sample Surface|Sample color from another surface on spawn.

Render
Render Type|Rendering type, surface or line.
Line Life|Line lifespan in frames.
Loop|Render the whole simulation before the first frame to create looping animation. Will have major impact to performance.
Round Position|Round position to the closest integer value to avoid anti-aliasing.
Sort Y|Sort particle by Y position before rendering.

Follow Path
Follow Path|Make particle follow path movement. This will added to particle initial position so set particle to spawn at [0,0] to have it\n
follow the path exactly.
Path Range|Range of path to follow.
Range Shift|Randomly shift path range per particle.
Path Speed|Path following curve.
Deviation|How much of the initial position to apply to the final position (Final position = Path position + Simulation position * Deviation).

Physics
Friction|Decrease speed by a fraction of the current speed per frame.
Acceleration|Increase, decrease speed by a fixed amount per frame.

Physics > Gravity
Gravity|Gravity strength

Physics > Turning
Turning|Apply constant rotation change to turn the particle.
Turn Both Directions|Apply randomized 1 or -1 multiplier to the turning speed.
Turn Scale with Speed|Scale turning speed with the current speed.

Ground
Collide Ground|Collide particle with a horizontal ground.
Ground Offset Type|Methods for setting ground Y position. Absolute for fixed ground for every particle, Relative will set ground relative to \n
particle spawn position.

Ground > Bounce
Bounce Amount|Bounce particle when hit the ground.
Bounce Friction|Reduce horizontal velocity when hitting the ground.

Wiggles
Direction|Randomly change particle direction.
Position|Randomly apply direct movement to the particle.
Rotation|Randomly rotate particle.
Scale|Randomly scale particle.
[/proptable]
