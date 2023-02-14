///fd_rectangle_draw_view(instance id, color, alpha, use interpolation)
function fd_rectangle_draw_view(domain, color, alpha, interpolate) {
	// Draws a fluid dynamics rectangle that has been attached to a view.
	// instance id: The instance id of the fluid dynamics rectangle.
	// color: The image blending color, the same as color in draw_surface_ext.
	// alpha: The alpha to draw at, the same as alpha in draw_surface_ext.
	// use interpolation: Set this to true if you want linear interpolation to be enabled, and false if you want nearest neighbor to be used instead.

	with (domain) {

	    fd_rectangle_shift_content(domain,
	            (view_xview_previous-__view_get( e__VW.XView, fd_view_number )) / fd_wratio,
	            (view_yview_previous-__view_get( e__VW.YView, fd_view_number )) / fd_hratio);
    
	    fd_rectangle_draw_part(id, fd_edge_buffer_size, fd_edge_buffer_size, 
	            __view_get( e__VW.WView, fd_view_number ) / fd_wratio, __view_get( e__VW.HView, fd_view_number ) / fd_hratio, 
	            __view_get( e__VW.XView, fd_view_number ), __view_get( e__VW.YView, fd_view_number ), 
	            fd_wratio, fd_hratio, color, alpha, interpolate);

	    view_xview_previous = __view_get( e__VW.XView, fd_view_number );
	    view_yview_previous = __view_get( e__VW.YView, fd_view_number );
	}




}
