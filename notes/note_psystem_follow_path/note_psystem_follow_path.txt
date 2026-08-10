Move particle along a path.

## Properties

[proptable]
Path
Path Range|Range of the path to follow.
Path Deviation|How much of the initial position to apply to the final position (Final position = Path position + Simulation position * Deviation).

Apply
Use Start Position|Offset path position by particle spawn position.
Stride|Instead of applying path position directly. Calculate path offset over stride distance and add it to particle position.
Spiral|Apply spiral movement from the spawn position around a path.
[/proptable]
