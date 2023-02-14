/// fd_rectangle_inherit_velocity(child instance id, parent instance id, inherit)
function fd_rectangle_inherit_velocity(childDomain, parentDomain, inherit) {
	// In some cases you want two (or more) different types of fluids in the same area and hence have to create several fluid dynamics rectangles over the same regions. Each fluid dynamics rectangle
	// will by default create and update its own velocity texture, but if you call this script you can set it to use the velocity field of another fluid dynamics rectangle. If it's okay that
	// the different types of fluids follow the same direction, this is greatly recommended as it can speed things up significantly. The velocity update is the slowest step in the simulation, so
	// inheriting a velocity field can make your game run much faster. Remember to call the update script for the parent fluid dynamics rectangle before the child fluid dynamics rectangle.
	// child instance id: The instance id of the fluid dynamics rectangle that will inherit the velocity.
	// parent instance id: The instance id of the fluid dynamics rectangle in control of the velocity update. The child instance inherits the velocity of this instance. If you're disabling inheritance
	//     you can set this to whatever you want.
	// inherit: Whether to inherit velocity (true) or not (false). This lets your disable or enable velocity inheritance.

	with (childDomain) {
	    inherit_velocity_parent = parentDomain;
	    inherit_velocity = inherit;
	}
}
