Create domain for GrainSim simulation.

## Properties

[proptable]
Domain
Size|Domain dimension (domain is always square shaped).
Gravity|Domain gravity.
Wall|Define solid wall around domain boundary.

Grain (global grain property)
Mass|Grain mass.
Granular|Control how solid the grain will act. Setting it to 0 will make group of grains moves as one solid object. Setting to 1 means each grain 
can moves fluidly.

Simulation
Timestep|Amount of time moved per update step. (Not recommend adjusting this value as it's extremely sensitive and can causes grain to 'explode'. Use update iteration to control animation speed.)
[/proptable]
