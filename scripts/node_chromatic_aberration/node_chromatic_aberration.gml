function Node_Chromatic_Aberration(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Chromatic Aberration";
	
	newActiveInput(3);
	
	////- =Surface
	newInput(0, nodeValue_Surface( "Surface In" ));
	
	////- =Effect
	newInput(5, nodeValue_Enum_Button( "Type",       0, [ "RGB", "Continuous" ] ));
	newInput(1, nodeValue_Vec2(        "Center",   [.5,.5] )).setHotkey("G").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(2, nodeValue_Slider(      "Strength",   1, [-16, 16, 0.01] )).setHotkey("S").setMappable(4);
	
	// input 6
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 
		["Surface",  false], 0, 
		["Effect",   false], 5, 1, 2, 4, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _cent = _data[1];
		var _type = _data[5];
		
		surface_set_shader(_outSurf, sh_chromatic_aberration);
			shader_set_interpolation(    _surf);
			shader_set_dim("dimension",  _surf);
			shader_set_i("type",         _type);
			shader_set_2("center",       _cent);
			shader_set_f_map("strength", _data[2], _data[4], inputs[2]);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _outSurf;
	}
}