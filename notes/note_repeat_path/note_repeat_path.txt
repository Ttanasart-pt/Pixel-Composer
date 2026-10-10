Repeat surface along path. Similar to <node Node_Repeat> but with the ability to deform object along path curvature.

## Properties

[proptable]
Output
Dimension|Output dimension.

Surface
Surface In|Input surface/surface array.
Array Selection|Whether to select surface from surface array randomly or by order.
Deform|Deformation amount.
Subdivision|Deformation level of detail.

Path
Path|Path data.

Repeat
Amount Type|Repeation type\n\t**Auto**: Repeat to fit the path length.\n\t**Fixed Amount**: Fix amount of copies\n\t**Fixed Distance** : Fix distance between each copies.
Amount|Amount of copies.
Distance|Distance between each copies.
Scale to Fit|For fixed type, adjsut the scale to fit space between each copies.
Path Overflow|If the last copy extends over the path. Whether to remove it, scale to fit, or crop.
Gap|Distance between each copies.

Rotation
Rotation|Base surface rotation.
Random Rotation|Apply random rotation per copies.

Scale
Scale|Base scale.
Random Scale|Apply random scale per copies.

Rendering
Color over Path|Apply blending color along path.
Color Random|Multiply each copies with random color.
[/proptable]
