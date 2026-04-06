<v 1.18.0/>
Spawn fluid particles from an area.

## Properties

### <junc spawn shape>
Shape of the spawn area.

### <junc spawn surface>
For surface spawn shape, the surface to spawn on.

### <junc spawn position>
Position of the spawn area.

### <junc spawn type>
Where to spawn the particles every frame (stream) or only once (splash).

- Stream: Spawn <junc spawn amount> particles per frame.
- Splash: Start spawning <junc spawn amount> particles at frame <junc spawn frame> for <junc spawn duration> frames.

### <junc spawn direction>
Apply initial directional velocity to the spawned particles.

### <junc spawn velocity>
Initial velocity of the spawned particles.

### <junc inherit velocity>
Apply the velopcity of the spawner (based on <junc spawn position>) to the spawned particles.