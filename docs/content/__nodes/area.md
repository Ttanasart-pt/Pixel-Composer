<v 1.18.0/>
Returns area data. Area data is simply a 5 dimensional vector that represents 2d bounding box. Each element of the vector represents the following:

1. X position of the middle point of the area.
2. Y position of the middle point of the area.
3. Half width of the area.
4. Half height of the area.
5. Shape of the area (0: Rectangle, 1: Ellipse).

This node allow you to create an area by combining vec2 <junc position>, vec2 <junc span> and integer <junc shape> inputs.