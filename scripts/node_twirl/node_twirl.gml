#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Twirl", "Oversample Mode > Toggle", "O", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 3); });
	});
#endregion

function Node_Twirl(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Twirl";
	
	newActiveInput(7);
	newInput(8, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	
	newInput(4, nodeValue_Enum_Scroll("Oversample Mode",  0, [ "Empty", "Clamp", "Repeat" ]));
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(5, nodeValue_Surface( "Mask" ));
	newInput(6, nodeValue_Slider(  "Mix", 1));
	__init_mask_modifier(5, 9); // inputs 9, 10
	
	////- =Twirl
	
	newInput(1, nodeValue_Vec2(   "Center",   [.5,.5] )).setHotkey("G").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(2, nodeValue_Slider( "Strength",   3, [-10, 10, 0.01])).setMappable(11);
	newInput(3, nodeValue_Float(  "Radius",    16 )).setMappable(12);
	
	// input 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 7, 8,
		["Surfaces", true],	0, 5, 6, 9, 10, 
		["Twirl",	false],	1, 2, 11, 3, 12,
	];
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var pos  = current_data[1];
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) { #region	
		var sam    = getAttribute("oversample");
		
		surface_set_shader(_outSurf, sh_twirl);
		shader_set_interpolation(_data[0]);
			shader_set_f("dimension" , surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_2("center"    ,   _data[1]);
			shader_set_f_map("strength", _data[2], _data[11], inputs[2]);
			shader_set_f_map("radius"  , _data[3], _data[12], inputs[3]);
			shader_set_i("sampleMode",   sam);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[8]);
		
		return _outSurf;
	} #endregion
}