#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Box", "Size > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Blur_Box(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Box Blur";
	
	newActiveInput(4);
	newInput(5, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(10, nodeValue_Surface( "UV Map"     ));
	newInput(11, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 2, nodeValue_Surface( "Mask"       ));
	newInput( 3, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(2, 6); // inputs 6, 7, 
	
	////- =Blur
	newInput( 8, nodeValue_Bool(  "Separate Axis",  false ));
	newInput( 1, nodeValue_Float( "Size",           3     )).setMappable(12).setHotkey("S").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput( 9, nodeValue_Float( "Size X",         3     )).setMappable(14);
	newInput(13, nodeValue_Float( "Size Y",         3     )).setMappable(15);
	newInput(16, nodeValue_Curve( "Intensity Modulation", CURVE_DEF_11 ));
	// input 17
	
	input_display_list = [ 4, 5, 
		[ "Surfaces", true ], 0, 10, 11, 2, 3, 6, 7, 
		[ "Blur",    false ], 8, 1, 12, 9, 14, 13, 15, 16, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Node
	
	temp_surface = [ noone ];
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[0];
			var _mask = _data[2];
			var _mix  = _data[3];
			
			var _sepa = _data[ 8];
			var _size = _data[ 1];
			var _sizX = _data[ 9];
			var _sizY = _data[13];
			
			var _intc = _data[16];
		
			inputs[ 1].setVisible(!_sepa);
			inputs[ 9].setVisible( _sepa);
			inputs[13].setVisible( _sepa);
		#endregion
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		temp_surface[0] = surface_verify(temp_surface[0], ww, hh, attrDepth());
		
		surface_set_shader(temp_surface[0], sh_blur_box);
			shader_set_interpolation(_data[0]);
			shader_set_uv(_data[10], _data[11]);
			
			shader_set_i("sampleMode", getAttribute("oversample"));
			shader_set_2("dimension", [ ww, hh ]);
			shader_set_i("axis",      0);
			shader_set_curve("intensity", _intc);
			
			if(_sepa) shader_set_f_map("size", _sizX, _data[14], inputs[9]);
			else      shader_set_f_map("size", _size, _data[12], inputs[1]);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_blur_box);
			shader_set_interpolation(_data[0]);
			shader_set_i("axis",      1);
			
			if(_sepa) shader_set_f_map("size", _sizY, _data[13], inputs[13]);
			else      shader_set_f_map("size", _size, _data[12], inputs[ 1]);
			
			draw_surface_safe(temp_surface[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		_outSurf = channel_apply(_data[0], _outSurf, _data[5]);
		
		return _outSurf;
	}
}