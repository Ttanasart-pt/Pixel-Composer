function Node_Gap_Contract(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gap Contract";
	
	newActiveInput(1);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(2, nodeValue_Surface( "Mask"       ));
	newInput(3, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(2, 4); // inputs 4, 5, 
	newInput(7, nodeValue_Bool( "Invert", false ));
	
	////- =Gap
	newInput(6, nodeValue_Int(  "Max Width", 8 )).setHotkey("S");
	/// inputs 8
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surfaces", false], 0, 2, 3, 4, 5, 7, 
		["Gap",      false], 6, 
	]
	
	temp_surface = [ noone, noone ];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var surf = _data[0];
		var _itr = _data[6];
		var _inv = _data[7];
		
		var _dim = surface_get_dimension(surf);
		
		for( var i = 0; i < 2; i++ ) temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		var _bg = 0;
		
		if(_inv) {
			surface_set_shader(temp_surface[1], sh_invert);
				shader_set_i("alpha", 0);
				draw_surface_safe(surf);
			surface_reset_shader();
		
		} else {
			surface_set_shader(temp_surface[1]);
				draw_surface_safe(surf);
			surface_reset_shader();
		}
		
		repeat(abs(_itr)) {
			surface_set_shader(temp_surface[_bg], sh_gap_contract);
				shader_set_2("dimension", _dim);
				shader_set_i("process",   _bg);
				shader_set_i("inverted",  _itr < 0);
				
				draw_surface_safe(temp_surface[!_bg]);
			surface_reset_shader();
			
			_bg = !_bg;
		}
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[!_bg]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		
		return _outSurf;
	}
}