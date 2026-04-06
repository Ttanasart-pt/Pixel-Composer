<v 1.18.0/>
Create FLIP fluid domain.

## Properties

### <junc dimension>
Size of the domain.

### <junc particle size>
Size of the fluid particles (in pixel).

### <junc wall>
Defines the existence of a wall in each sides.

### <junc wall elasticity>
Bounciness of the wall.

### <junc flip ratio>
The ratio of FLIP influence to PIC influence (0 being all PIC and 1 being all FLIP). 

PIC (particle in cell) tends to be more stable but less detailed, while FLIP is more turbulent but less stable.

### <junc time step>
Time step of the simulation. Larger time step will make the simulation faster but less accurate.

### <junc gravity>
Gravity force.

### <junc gravity direction>
Direction of the gravity force.

### <junc viscosity>
Viscosity, stickyness of the fluid.

### <junc friction>
Energy loss when particles collide.