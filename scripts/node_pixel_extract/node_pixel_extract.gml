function Node_Pixel_Extract(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Extract";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newOutput(0, nodeValue_Output("Colors", self, VALUE_TYPE.color, [ ]))
		.setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [
		["Surfaces", true],	0, 
	]
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		if(!is_surface(_surf)) return [];
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		var _pixels = array_create(ww * hh);
		
		var c_buffer = buffer_create(1, buffer_grow, 4);
		buffer_get_surface(c_buffer, _surf, 0);
		buffer_seek(c_buffer, buffer_seek_start, 0);
		
		var amo = ww * hh;
		for( var i = 0; i < amo; i++ )
			_pixels[i] = buffer_read(c_buffer, buffer_u32);
		
		buffer_delete(c_buffer);
		
		return _pixels;
	}
	
	static getPreviewValues = function() { return getInputData(0); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
	    var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var pal = outputs[0].getValue();
		drawPalette(pal, bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}