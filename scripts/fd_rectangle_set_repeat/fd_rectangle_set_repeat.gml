/// fd_rectangle_set_repeat(instance id, repeat)
function fd_rectangle_set_repeat(domain, wrap) {
	// Set this to true if you want the fluid to wrap around the texture, as in when it goes to the right end of fluid dynamics rectangle
	// it will wrap around to the left end.
	// instance id: The instance id of the fluid dynamics rectangle.
	// repeat: True to enable repeat, false to disable it.

	domain.texture_repeat = wrap;
}
