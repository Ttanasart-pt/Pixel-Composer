<img-deco grid/>



## Properties


### <junc gap/>


Thickness of the gap between grid.




### <junc shift/>


Shift every even row by a fix amount to create brick pattern.


### <junc shift axis/>


The axis to apply shift to.



## Rendering Modes


### Colored Tile


Fill each grid with different color sampled from the <junc tile color/> property.

The <junc gap color/> 
control the color of the gap between tile.


<img-deco grid_colored_tile/>


### Height Map


Render the grid out as height map.


<img-deco grid_height_map/>


### Texture Grid


Fill each grid with the texture from the <junc texture/> property. This mean each cell will contain the 
full surface.


<img-deco grid_texture_grid/>


### Texture Sampler


Fill each cell with solid color sampled from the <junc texture/>.


<img-deco grid_texture_sampler/>



## Truchet Properties


Toggling on the <junc truchet/> when using the <span class="inline-code">Texture Grid</span> mode will rotate 
the sampled texture randomly. Using this effect with a surface with rotational symmetry to create an interesting image.


<img-deco grid_truchet/>


### Flip


The <junc flip horizontal/> and <junc flip vertical/> properties are used to control how often a surface will 
be flip on each axis accordingly.


### Angle


The <junc angle/> property adds random rotation to each surface.

