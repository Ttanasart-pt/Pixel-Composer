/// fd_rectangle_get_velocity_surface(instance id)
function fd_rectangle_get_velocity_surface(domain) {
	// Returns the velocity surface of a fluid dynamics rectangle.
	// Format:
	// There are 4 channels, so 8*4 bits in total. The x velocity gets 16 bits and the y velocity gets 16 bits.
	// This means the x and y velocity covers two channels each. The x velocity will cover the red and blue channel, and
	// the y velocity will cover the green and alpha channel. The most significant bits will be in the first channel (red for
	// x, and green for y). Since the color channels are unsigned values from 0 to 255, and signed values are essential for
	// velocities, the range is shifted to make everything below 128 negative, and anything above 128 positive, meaning that a value
	// of 128 corresponds to no velocity.
	// See the example code's obj_fd_example_leaf for an example implementation on how to extract velocity from this format.
	// instance id: The instance id of the fluid dynamics rectangle.

	return domain.sf_velocity;



}
