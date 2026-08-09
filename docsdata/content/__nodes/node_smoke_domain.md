<v 1.18.0/>
Create smoke simulation domain.

## Properties

[proptable]
Domain
Dimension|Size of the domain.
Boundary|Domain boundary type:\n
 - **Free**: Open boundary, smoke disappear when overflow.\n
 - **Wall**: Close boundary, solid walls surround the domain.\n
 - **Wrap**: Wrap the domain around the edges.
Collision|A surface defining the solid part of the domain.

Properties
Initial Pressure|Pressure, density of the empty space.
Acceleration|Global acceleration.
Material Intertia|How much the material resists to change its velocity.

Dissipation
Material Dissipation|How much the material spreads out to empty space.
Velocity Dissipation|How much the velocity spreads out to equilibrium.
[/proptable]