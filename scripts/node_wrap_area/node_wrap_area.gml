function Node_Wrap_Area(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Area Warp";
	
	newInput(0, nodeValue_Surface("Surface In"));

	onSurfaceSize = function() /*=>*/ {return surface_get_dimension(getInputData(0))};
	newInput(1, nodeValue_Area("Area", DEF_AREA_REF, { onSurfaceSize, useShape : false })).setHotkey("A").setUnitSimple();
	
	newActiveInput(2);
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 2,
		["Surfaces", false], 0, 
		["Area",	 false], 1, 
	]
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_interpolation();

	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _inSurf	= _data[0];
		if(!is_surface(_inSurf)) return _outSurf;
		
		var _area	= _data[1];
		if(!is_array(_area) && array_length(_area) < 4)
			return _outSurf;
		
		var cx = _area[0];
		var cy = _area[1];
		var cw = _area[2];
		var ch = _area[3];
		
		var ww = cw / surface_get_width_safe(_inSurf) * 2;
		var hh = ch / surface_get_height_safe(_inSurf) * 2;
		
		surface_set_shader(_outSurf);
		shader_set_interpolation(_inSurf);
		draw_surface_ext_safe(_inSurf, cx - cw, cy - ch, ww, hh, 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}