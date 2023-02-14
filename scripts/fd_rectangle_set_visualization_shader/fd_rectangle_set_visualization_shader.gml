/// fd_rectangle_set_visualization_shader(instance id, shader)
function fd_rectangle_set_visualization_shader(domain, shader) {
	// Sets the visualization shader for the fluid dynamics rectangle.
	// instance id: The instance id of the fluid dynamics rectangle.
	// shader: You can enter your own custom shader (see the internal shaders for how visualization shaders work), or you can enter
	//     one of the elements of this enum, FD_VISUALIZATION_SHADER:
	//     FD_VISUALIZATION_SHADER.NO_SHADER: No shader will be used, and the fluid dynamics will be drawn like it is behind the scenes.
	//     FD_VISUALIZATION_SHADER.DEBUG_VELOCITY: Shows the velocity.
	//     FD_VISUALIZATION_SHADER.DEBUG_VELOCITY_DIVERGENCE: Shows the velocity divergence.
	//     FD_VISUALIZATION_SHADER.DEBUG_PRESSURE: Shows the pressure.
	//     FD_VISUALIZATION_SHADER.PIXEL_ART_FIRE: Pixelates the fluid and adds thresholds to determine different fire colors.
	//     FD_VISUALIZATION_SHADER.COLORIZE: Draws the fluid with one color everywhere. To change the color, go to the internal shader called sh_fd_visualize_colorize_glsl.
	//     FD_VISUALIZATION_SHADER.PIXEL_ART_FIERY_SMOKE: A lot like PIXEL_ART_FIRE, but a layer of gray is added as well.
	//     FD_VISUALIZATION_SHADER.THICK_SMOKE: Draws the fluid with lighting and a threshold making it look thicker.

	domain.visualization_shader = shader;
}
