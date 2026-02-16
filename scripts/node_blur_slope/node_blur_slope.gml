#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Slope", "Strength > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Blur_Slope(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Slope Blur";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(12, nodeValue_Surface( "UV Map"     ));
	newInput(13, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	newInput( 4, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(3, 7); // inputs 7, 8
	
	////- =Blur
	newInput( 2, nodeValue_Surface( "Slope Map" ));
	newInput( 1, nodeValue_Slider(  "Strength",   4, [1, 32, 0.1 ] )).setHotkey("S").setMappable(9).setCurvable(14);
	newInput(10, nodeValue_Slider(  "Step",      .1, [0,  1, 0.01] ));
	newInput(11, nodeValue_Bool(    "Gamma Correction", false ));
	// input 15
	
	input_display_list = [ 5, 6, 
		["Surfaces", true],  0, 12, 13,  3,  4,  7,  8, 
		["Blur",	false],  2,  1,  9, 14, 10, 11, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0]; 
		var _slop = _data[2]; 
		
		if(!is_surface(_surf)) return _outSurf;
		
		surface_set_shader(_outSurf, sh_blur_slope);
			shader_set_interpolation(_surf);
			shader_set_i("sampleMode",	  getAttribute("oversample"));
			shader_set_uv(_data[12], _data[13]);
			
			shader_set_f("dimension",     surface_get_dimension(_surf));
			shader_set_f_map("strength",  _data[1], _data[ 9], inputs[1], _data[14]);
			shader_set_f("stepSize",      _data[10]);
			
			shader_set_s("slopeMap",      _slop);
			shader_set_f("slopeMapDim",   surface_get_dimension(_slop));
			
			shader_set_i("gamma",         _data[11]);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}