function Node_Wrap_Area(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Area Warp";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16, 4, 4, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, function() { return getDimension(0); });
	
	inputs[| 2] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 2;
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 2,
		["Surface",	 false], 0, 
		["Area",	 false], 1, 
	]
	
	attribute_surface_depth();

	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _inSurf	= _data[0];
		if(!is_surface(_inSurf)) return _outSurf;
		
		var _area	= _data[1];
		if(!is_array(_area) && array_length(_area) < 4)
			return _outSurf;
		
		var cx = _area[0];
		var cy = _area[1];
		var cw = _area[2];
		var ch = _area[3];
		
		var ww = cw / surface_get_width(_inSurf) * 2;
		var hh = ch / surface_get_height(_inSurf) * 2;
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE;
			
			draw_surface_ext_safe(_inSurf, cx - cw, cy - ch, ww, hh, 0, c_white, 1);
			
			BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}