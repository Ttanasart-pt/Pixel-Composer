function Node_Pixel_Extract(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Extract";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Enum_Button("Skip", 0, [ "None", "Black", "Empty" ]));
	
	newOutput(0, nodeValue_Output("Colors", VALUE_TYPE.color, [ ]))
		.setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [
		["Surfaces", false], 0,
		["Output",   false], 1, 
	]
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _skip = _data[1];
		if(!is_surface(_surf)) return [];
		
		var ww  = surface_get_width_safe(_surf);
		var hh  = surface_get_height_safe(_surf);
		var amo = ww * hh;
		var _pixels = array_create(amo);
		
		var c_buffer = buffer_create(1, buffer_grow, 4);
		buffer_get_surface(c_buffer, _surf, 0);
		buffer_seek(c_buffer, buffer_seek_start, 0);
		for( var i = 0; i < amo; i++ )
			_pixels[i] = buffer_read(c_buffer, buffer_u32);
		buffer_delete(c_buffer);
		
		switch(_skip) {
			case 1 : _pixels = array_filter(_pixels, function(c) /*=>*/ {return c & 0x00FFFFFF != 0}) break;
			case 2 : _pixels = array_filter(_pixels, function(c) /*=>*/ {return c != 0})              break;
		}
		
		return _pixels;
	}
	
	static getPreviewValues = function() { return getInputData(0); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
	    var bbox = draw_bbox;
		if(bbox.h < 1) return;
		
		var pal = outputs[0].getValue();
		drawPalette(pal, bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}