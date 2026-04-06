FLIP Fluid simulation is a group of nodes used to simulate fluid behaviour using Fluid-Implicit-Particle (FLIP) 
algorithm.



## FLIP Fluid nodes


To see the list and detail of all FLIP Fluid nodes, check out <a href="../flip fluid/">FLIP Fluid</a> section.



## System Overview


The FLIP fluid system consists of 3 main parts, the domain, particle and renderer. When selecting this 
node from the add node menu, 3 nodes will be created:


<img-deco flip_init/>



### <node flip_domain/>


Fluid domain represent a space where a fluid can exist. This node contain properties to 
control particle grid size, fluid physics, solver settings, etc.



### <node flip_spawner/>


Spawn fluid particles to represent fluid volume.



### <node flip_render/>


Render out fluid particles to a surface.


