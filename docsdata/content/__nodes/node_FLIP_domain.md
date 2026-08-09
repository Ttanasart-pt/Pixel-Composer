Create FLIP fluid domain.

## Properties

[proptable]
Domain
Dimension|Size of the domain.
Particle Size|Size of the fluid particles (in pixel).
Wall|Defines the existence of a wall in each sides.
Wall Elasticity|Bounciness of the wall.

Solver
FLIP Ratio|The ratio of FLIP influence to PIC influence (0 being all PIC and 1 being all FLIP). \n
PIC (particle in cell) tends to be more stable but less detailed, while FLIP is more turbulent but less stable.
Time Step|Time step of the simulation. Larger time step will make the simulation faster but less accurate.

Physics
Damping|Global slow down factor for all particles.
Gravity|Gravity force.
Gravity Direction|Direction of the gravity force.
Viscosity|Viscosity, stickyness of the fluid.
Friction|Energy loss when particles collide.
[/proptable]