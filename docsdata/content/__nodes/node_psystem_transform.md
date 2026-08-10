Apply transformation to particles.

## Properties

[proptable]
Direct Move
Direct Move|Move particle directly by setting x,y offset per frame.

Vector Move
Vector Move|Apply movement vector to particle, movement vector will accumulate so particle will move faster overtime.
Vector Impulse|Apply vector once when particle spawn to prevent acceleration (speed over lifespan curve will have no impact).
Speed|Movement vector speed.
Direction|Movement vector direction.

Rotation
Rotation|Rotate particle.
Mode|Rotation application mode\n
 - **Add**: Add <junc rotation> to current particle rotation per frame.\n
 - **Multiply**: Multiply <junc rotation> to current particle rotation per frame.\n
 - **Override**: Override particle rotation with <junc rotation>.
Rotate|Rotation amount.

Scale
Scale|Scale particle.
Mode|Scale application mode\n
 - **Add**: Add <junc scale> to current particle scale per frame.\n
 - **Multiply**: Multiply <junc scale> to current particle scale per frame.\n
 - **Override**: Override particle scale with <junc scale>.
Accumulative|Whether to pply scale modification to the current scale or initial spawning scale (use in conjunction with scale curve).
Scale|Scale amount.
[/proptable]
