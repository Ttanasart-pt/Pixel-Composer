function Node_Find_Pixel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Find pixel";
	w = 96;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Search color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 2] = nodeValue("Tolerance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Find all", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	outputs[| 0] = nodeValue("Position", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static getPreviewValues = function() { return getInputData(0); }
	
	temp_surface = [ surface_create(1, 1) ];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _surf = _data[0];
		var _col  = _data[1];
		var _tol  = _data[2];
		var _all  = _data[3];
		
		if(!is_surface(_surf)) return [0, 0];
		
		var _buff = buffer_from_surface(_surf, false);
		var _sw   = surface_get_width_safe(_surf);
		var _sh   = surface_get_height_safe(_surf);
		buffer_seek(_buff, buffer_seek_start, 0);
		
		var res = [];
		var r = color_get_red(_col)   / 255;
		var g = color_get_green(_col) / 255;
		var b = color_get_blue(_col)  / 255;
		
		for( var i = 0; i < _sh; i++ ) 
		for( var j = 0; j < _sw; j++ ) {
			var _c = buffer_read(_buff, buffer_u32);
			
			var _r = ((_c & 0x000000FF) >>  0) / 255;
			var _g = ((_c & 0x0000FF00) >>  8) / 255;
			var _b = ((_c & 0x00FF0000) >> 16) / 255;
			var _a = ((_c & 0xFF000000) >> 24) / 255;
			
			if(_a == 0) continue;
			
			if((abs(r - _r) + abs(g - _g) + abs(b - _b)) / 3 <= _tol) {
				if(_all) array_push(res, [ j, i ]);
				else     return [ j, i ];
			}
		}
		
		buffer_delete(_buff);
		return _all? res : [ -1, -1 ];
		
		//temp_surface[0] = surface_verify(temp_surface[0], 1, 1);
		
		//surface_set_shader(temp_surface[0], sh_find_pixel);
		//	shader_set_surface("texture", _surf);
		//	shader_set_dim("dimension", _surf);
		//	draw_sprite_ext(s_fx_pixel, 0, 0, 0, 1, 1, 0, _col, 1);
		//surface_reset_shader();
		
		//var pos = surface_get_pixel(temp_surface[0], 0, 0);
		//var _x  = round(color_get_red(pos)   / 255 * surface_get_width_safe(_surf));
		//var _y  = round(color_get_green(pos) / 255 * surface_get_height_safe(_surf));
		
		//return [ _x, _y ];
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(bbox.h <= 0) return;
		
		var col = getInputData(1);
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		draw_set_color(col);
		draw_rectangle(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 0);
	} #endregion
}