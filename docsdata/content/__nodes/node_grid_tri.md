Generate triangular grid pattern.


<img-deco grid_tri/>



## Properties


### <junc gap/>


The thickness of the gap between cell.



## Rendering Modes


### Colored Tile


Fill each cell with a solid random color sampled from the <junc tile color/> value.


<img-deco grid_tri_colored_tile/>


### Height Map


Render each cell out as a heightmap.


<img-deco grid_tri_height_map/>


### Texture Grid


Render out the surface value from <junc texture/> to each cell.


<img-deco grid_tri_texture_grid/>


### Texture Sample


Fill each cell with a solid color sampled from the <junc texture/> value.


<img-deco grid_tri_texture_sampler/>


## Truchet Properties


Similiar to other grid related nodes. Truchet settings rotate the surface randomly to create an interesting effect.


### <junc truchet threshold/>


The ratio of the rotation.


### <junc texture angle/>


Apply random rotation on top of the truchet.

