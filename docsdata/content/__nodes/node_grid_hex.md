Generate hexagonal grid, honeycomb pattern.


<img-deco grid_hex/>



## Properties


### <junc gap/>


Thickness of the gap between each cell.



## Rendering Modes


### Colored Tile


Fill each cell with a solid random color sampled from the <junc tile color/> value.


<img-deco grid_hex_colored_tile/>


### Height Map


Render each cell out as a heightmap.


<img-deco grid_hex_height_map/>


### Texture Grid


Render out the surface value from <junc texture/> to each cell.


<img-deco grid_hex_texture_grid/>


### Texture Sample


Fill each cell with a solid color sampled from the <junc texture/> value.


<img-deco grid_hex_texture_sampler/>


## Truchet Properties


Similiar to the <node grid/> node. Truchet settings rotate the surface randomly to create an interesting effect.


<img-deco grid_hex_truchet/>


### <junc truchet threshold/>


The ratio of the rotation.


### <junc texture angle/>


Apply random rotation on top of the truchet.

