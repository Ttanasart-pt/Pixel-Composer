/// fd_rectangle_create_view(sf width, sf height, view number, edge buffer size)
function fd_rectangle_create_view(width, height, view, edge_buffer) {
	// Creates a fluid dynamics rectangle attached to a view and returns its instance id. This instance id should be stored and be used together with the other scripts of this asset.
	// sf width, sf height: The width and height of the fluid dynamics rectangle. This does not need to be the same as the amount of pixels it will cover. It's usually a good idea to make
	//     it about a third the size of what it will actually cover on screen.
	// view number: The view to attach the fluid dynamics rectangle to.
	// edge buffer size: The number of pixels of padding to add around the view for the fluid dynamics rectangle.

	with (fd_rectangle_create(width + (2 * edge_buffer), height + (2 * edge_buffer))) {
	    fd_edge_buffer_size = edge_buffer;
	    fd_view_number = view;
	    fd_wratio = __view_get( e__VW.WView, fd_view_number ) / width;
	    fd_hratio = __view_get( e__VW.HView, fd_view_number ) / height;
	    view_xview_previous = __view_get( e__VW.XView, fd_view_number );
	    view_yview_previous = __view_get( e__VW.YView, fd_view_number );
	    return id;
	}
}
