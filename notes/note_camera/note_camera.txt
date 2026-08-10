[banner]
Associated tutorial: **Composing**
[/banner]

Camera node used to capture parts of the scene. You can think of it as a 2D camera with fix dimension 
looking around your image.

Camera node also allows for parallax and Depth of Field effect.

## Properties

[proptable]
Camera
Focus Center|Center point of the camera target.
Zoom|Scale the surface.

FOV
Depth of Field|Apply depth of field effect cased on surface septh.
Focal Distance|Middle depth level for sharp output.
Focal Range|Range depth where output stays sharp.
[/proptable]

## Parallax

Camera node allows for parallax effect by layering multiple surfaces at different depth.

The extra surface can be added to the <junc element {_s}> properties. When 
the new element is added, you can change the position setting in the <junc parallax {_s}>
property. The X and Y value indicate the parallax direction, and the Z value use to control the speed in which 
the surface will be moved with the camera.

<img node_camera_parallax>

Note that the speed of parallax is depends on both XY and Z axis. If both X and Y are set to 0, then 
there will be no parallax effect.