/// fd_rectangle_draw_part(instance id, left, top, width, height, x, y, xscale, yscale, color, alpha, use interpolation)
function fd_rectangle_draw_part(domain, left, top, width, height, _x, _y, xscale, yscale, color, alpha, interpolate) {
	// Draws a part of the fluid dynamics rectangle.
	// instance id: The instance id of the fluid dynamics rectangle.
	// left, top, width, height: See the manual on draw_surface_part for an explanation.
	// x, y: The pixel position to draw at.
	// _x, _y: The scale to draw at.
	// color: The image blending color, the same as color in draw_surface_ext.
	// alpha: The alpha to draw at, the same as alpha in draw_surface_ext.
	// use interpolation: Set this to true if you want linear interpolation to be enabled, and false if you want nearest neighbor to be used instead.

	with (domain) {
	    texture_set_interpolation(interpolate);
		
	    fd_rectangle_assure_surfaces_exist(id);
		
	    shader_set(sh_fd_visualize_colorize_glsl);
	        draw_surface_part_ext(sf_material_0, left, top, width, height, _x, _y, xscale, yscale, color, alpha);
	    shader_reset();
		
		texture_set_interpolation(false);
	}



}
