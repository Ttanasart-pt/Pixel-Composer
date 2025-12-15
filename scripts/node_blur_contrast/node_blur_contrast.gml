#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Contrast", "Size > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Blur_Contrast(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Contrast Blur";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(10, nodeValue_Surface( "UV Map"     ));
	newInput(11, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	newInput( 4, nodeValue_Slider(  "Mix",    1  ));
	__init_mask_modifier(3, 7); // inputs 7, 8
	
	////- =Blur
	newInput( 1, nodeValue_Float(  "Size",        .25 )).setMappable(12).setHotkey("S").setValidator(VV_min(0)).setUnitSimple();
	newInput( 2, nodeValue_Slider( "Threshold",  .2 )).setMappable(13).setTooltip("Brightness different to be blur together.");
	newInput( 9, nodeValue_Bool(   "Gamma Correction", false ));
	// input 14
	
	input_display_list = [ 5, 6, 
		[ "Surfaces",  true ],  0, 10, 11,  3,  4,  7,  8, 
		[ "Blur",     false ],  1, 12,  2, 13,  9, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Node
	
	temp_surface = [ noone ];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _size = _data[1];
		var _tres = _data[2];
		var _mask = _data[3];
		var _mix  = _data[4];
		var _gam  = _data[9];
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		
		surface_set_shader(_outSurf, sh_blur_box_contrast);
			shader_set_interpolation(_surf);
			shader_set_uv(_data[10], _data[11]);
			
			shader_set_f("dimension", [ ww, hh ]);
			shader_set_f_map("size",     _size, _data[12], inputs[1] );
			shader_set_f_map("treshold", _tres, _data[13], inputs[2] );
			shader_set_i("gamma",        _gam);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}