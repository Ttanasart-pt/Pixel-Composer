<v 1.18.0/>
Spawn fluid particles from an area.

## Properties

[proptable]
Spawner
Spawn Shape|Shape of the spawn area.
Spawn Surface|For surface spawn shape, the surface to spawn on.
Spawn Position|Position of the spawn area.
Spawn Type|Where to spawn the particles every frame (stream) or only once (splash).\n
- Stream: Spawn <junc spawn amount> particles per frame.\n
- Splash: Start spawning <junc spawn amount> particles at frame <junc spawn frame> for <junc spawn duration> frames.

Physics
Spawn Direction|Apply initial directional velocity to the spawned particles.
Spawn Velocity|Initial velocity of the spawned particles.
Inherit Velocity|Apply the velopcity of the spawner (based on <junc spawn position>) to the spawned particles.
[/proptable]