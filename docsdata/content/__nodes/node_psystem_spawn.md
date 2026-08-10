Spawn particles. Most properties are shared with <node Node_Particle>.

## Properties

[proptable]
Spawn
Spawn Type|Spawn Timing\n
 - **Stream**: Spawn particles constantly.\n
 - **Burst**: Spawn particles once in burst.\n
 - **Trigger**: Spawn particles using manual/automatic trigger.
Spawn Delay|For Stream type, frames delay between each particle spawn.
Spawn Frame|For Burst type, frame index to spawn.
Burst Duration|For Burst type, amount of frames to spawn.
Spawn Amount|Amount of particles to spawn per frame.
Lifespan|Particle lifespan.

Spawn > Source
Spawn Source|Type of particle spawn source.\n
 - **Area Inside**: Spawn inside an area.\n
 - **Area Border**: Spawn around area border.\n
 - **Map**: Spawn based on greyscale surface.\n
 - **Path**: Spawn along a path.\n
 - **Direct Data**: Spawn from array of vec2 points.
Distribution|For area, path source, particle spawning pattern.
Period|For uniform distribution, define distribution amount (e.g. if set to 4, particle will spawn at 4 fixed points in the source.)\n
If set to zero, will use <junc Spawn Amount>.

Transform
Inherit Velocity|When spawning particle using a trigger from another particle. Whether to inherit velocity from the caller particle and how much.
Direction|Initial spawn direction.
Velocity|Initial velocity.

Scale
Scale|Define non-uniform particle scale.
Size|Uniform particle scale.

Events
Step Period|How often will the particle call step event (e.g. if set to 2, will trigger step event once every 2 frames).
[/proptable]
