function Node_Dilate(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Dilate";
	
	newActiveInput(7);
	newInput(8, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	/* UNUSED */ newInput(4, nodeValue_EScroll( "Oversample mode",  0, [ "Empty", "Clamp", "Repeat" ]));
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(13, nodeValue_Surface( "UV Map"     ));
	newInput(14, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 5, nodeValue_Surface( "Mask"       ));
	newInput( 6, nodeValue_Slider(  "Mix",    1  ));
	__init_mask_modifier(5, 9); // inputs 9, 10
	
	////- =Dilate
	newInput(1, nodeValue_Vec2(   "Center",   [.5,.5]        )).setHotkey("G").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(2, nodeValue_Slider( "Strength",  1, [-3,3,.01] )).setHotkey("S").setMappable(11).setCurvable(15, CURVE_DEF_01);
	newInput(3, nodeValue_Float(  "Radius",   .5             )).setHotkey("R").setMappable(12).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	// input 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 7, 8, 
		["Surfaces", true],	 0, 13, 14,  5,  6,  9, 10, 
		["Dilate",	false],	 1,  2, 11, 15,  3, 12,
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		var pos = current_data[1];
		var rad = current_data[3];
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		if(is_real(rad)) draw_circle_dash(px, py, rad * _s);
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 90, _dim[0] / 2, 2));
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active,  px,  py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var sam    = getAttribute("oversample");
		
		surface_set_shader(_outSurf, sh_dilate);
			shader_set_interpolation(_data[0]);
			shader_set_uv(_data[13], _data[14]);
			
			shader_set_f("dimension", [ surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]) ]);
			shader_set_2("center",         _data[1]);
			shader_set_f_map("strength",   _data[2], _data[11], inputs[2], _data[15]);
			shader_set_f_map("radius",     _data[3], _data[12], inputs[3]);
			
			shader_set_i("sampleMode", sam);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[8]);
		
		return _outSurf;
	}
}