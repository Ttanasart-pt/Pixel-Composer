/// fd_rectangle_set_initial_value_pressure(instance id, initial value)
function fd_rectangle_set_initial_value_pressure(domain, value) {
	// This sets the initial value that all pixels are cleared to before performing pressure iteration.
	// instance id: The instance id of the fluid dynamics rectangle.
	// initial value: A value between 0 and 1. Usually you want to use 0.5, but you might want to experiment with different values
	//     to see if you get a result that looks better for your implementation.

	domain.initial_value_pressure = value;
}
