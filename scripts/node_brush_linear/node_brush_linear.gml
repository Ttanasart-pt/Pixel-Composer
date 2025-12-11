function Node_Brush_Linear(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Brush";
	
	newActiveInput(1);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(7, nodeValue_Surface( "Mask"       ));
	newInput(8, nodeValue_Slider(  "Mix",     1 ));
	newInput(9, nodeValue_Toggle(  "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	__init_mask_modifier(7, 10); // inputs 10, 11
	
	////- =Effect
	newInput(3, nodeValueSeed());
	newInput(2, nodeValue_Int(    "Iteration",    10 )).setHotkey("I").setValidator(VV_min(1));
	newInput(4, nodeValue_Float(  "Length",       10 )).setMappable(12).setHotkey("L");
	newInput(5, nodeValue_Slider( "Attenuation", .99 )).setMappable(13).setCurvable(15);
	newInput(6, nodeValue_Slider( "Circulation", .8  )).setMappable(14);
	// input 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1,
		["Surface", false],  0,  7,  8,  9, 10, 11, 
		["Effect",  false],  2,  4, 12,  5, 13, 15,  6, 14,  
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy - ui(16), _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _cx, _cy + ui(16), _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _seed = _data[3];
			var _itr  = _data[2];
		#endregion
		
		surface_set_shader(_outSurf, sh_brush_linear);
			shader_set_f("dimension",  surface_get_dimension(_data[0]));
			shader_set_f("seed",         _seed );
			shader_set_i("iteration",    _itr  );
			shader_set_f_map("brushLen", _data[4], _data[12], inputs[4] );
			shader_set_f_map("brushAtn", _data[5], _data[13], inputs[5], _data[15] );
			shader_set_f_map("brushRot", _data[6], _data[14], inputs[6] );
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[7], _data[8]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[9]);
		
		return _outSurf;
	}
}