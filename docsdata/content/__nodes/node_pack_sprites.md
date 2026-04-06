Pack sprites nodes allows for quick composition of surfaces array with different sizes.



## Packing Algorithms


### Skyline


Skyline packing place surfaces next to each other horizontally until it reach <junc max width/>, then it goes to the beginning 
of the row and search for the best fit for the next surface. It is a very fast algorithm but it can leave a lot of empty space.


### Shelf


Shelf packing place surfaces next to each other horizontally until it reach <junc max width/> while keeping the same height, 
then it goes to the next row.


### Top left


Top left packing sort the surfaces by height and always try to place the next surface in the top left corner of the leftover space.


### Best fit


Best fit is the slowest algorithm. It sort all surfaces by size and search for the best fit for each subsequent surface.


