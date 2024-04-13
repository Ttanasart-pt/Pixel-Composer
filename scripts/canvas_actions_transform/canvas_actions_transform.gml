function canvas_action_rotate(angle, _resize = true) {
	storeAction();
	
	var _dim = attributes.dimension;
	var _pos = point_rotate(0, 0, _dim[0] / 2, _dim[1] / 2, angle);
	
	for( var i = 0; i < attributes.frames; i++ ) {
		var _canvas_surface = getCanvasSurface(i);
						
		var _newCanvas = surface_create(_dim[0], _dim[1]);
		surface_set_shader(_newCanvas, noone);
			draw_surface_ext(_canvas_surface, _pos[0], _pos[1], 1, 1, angle, c_white, 1);
		surface_reset_shader();
						
		setCanvasSurface(_newCanvas, i);
		surface_free(_canvas_surface);
	}
	
	triggerRender();
}

function canvas_action_flip(axis) {
	storeAction();
	
	var _dim = attributes.dimension;
	
	for( var i = 0; i < attributes.frames; i++ ) {
		var _canvas_surface = getCanvasSurface(i);
						
		var _newCanvas = surface_create(_dim[0], _dim[1]);
		surface_set_shader(_newCanvas, noone);
			if(axis == 0) draw_surface_ext(_canvas_surface, 0, _dim[1], 1, -1, 0, c_white, 1);
			if(axis == 1) draw_surface_ext(_canvas_surface, _dim[0], 0, -1, 1, 0, c_white, 1);
		surface_reset_shader();
						
		setCanvasSurface(_newCanvas, i);
		surface_free(_canvas_surface);
	}
	
	triggerRender();
}