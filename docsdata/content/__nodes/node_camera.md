Camera node used to capture parts of the scene. You can think of it as a 2D camera with fix dimension 
looking around your image.


Camera node also allows for parallax and Depth of Field effect.



## Camera Properties


The <junc focus area> is an array data controlling the camera size and position.


The <junc zoom> property allows you to scale the image.


## Parallax


Camera node allows for parallax effect by layering multiple surfaces at different depth.


The extra surface can be added to the <junc element {_s}> properties. When 
the new element is added, you can change the position setting in the <junc parallax {_s}>
property. The X and Y value indicate the parallax direction, and the Z value use to control the speed in which 
the surface will be moved with the camera.


<img node_camera_parallax>


Note that the speed of parallax is depends on both XY and Z axis. If both X and Y are set to 0, then 
there will be no parallax effect.



## Depth of Field


Camera node can simulate basic Depth of Field effect using the Z value of the object as a distance from 
camera


<img node_camera_dof>


The <junc Focal Distance> control where the sharpest depth will be, 
the <junc Focal Range> control the range where the object stays sharp 
and <junc Defocus> control how much blur will applies to object further away.