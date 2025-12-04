#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Radial", "Strength > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Blur_Radial(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Radial Blur";
	
	newActiveInput(6);
	newInput( 7, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 3, nodeValue_Enum_Scroll("Oversample mode", 0, [ "Empty", "Clamp", "Repeat" ]));
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(12, nodeValue_Surface( "UV Map"     ));
	newInput(13, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 4, nodeValue_Surface( "Mask"       ));
	newInput( 5, nodeValue_Slider(  "Mix",    1  ));
	__init_mask_modifier(4, 8); // inputs 8, 9
	
	////- =Blur
	newInput( 1, nodeValue_Rotation( "Strength",          45     )).setHotkey("R").setMappable(10);
	newInput( 2, nodeValue_Vec2(     "Center",           [.5,.5] )).setHotkey("G").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(11, nodeValue_Bool(     "Gamma Correction",  false  ));
	// input 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 6, 7, 
		["Surfaces", true],	0, 12, 13, 4, 5, 8, 9, 
		["Blur",	false],	1, 10, 2, 11, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var pos  = getInputData(2);
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {		
		var _surf = _data[ 0];
		
		var _cen  = _data[ 2];
		var _gam  = _data[11];
		
		var sw = surface_get_width_safe(_surf);
		var sh = surface_get_height_safe(_surf);
		_cen = [_cen[0] / sw, _cen[1] / sh];
		
		surface_set_shader(_outSurf, sh_blur_radial);
			shader_set_interpolation(_surf);
			shader_set_uv(_data[12], _data[13]);
			
			shader_set_f("dimension",    sw, sh);
			shader_set_f_map("strength", _data[1], _data[10], inputs[1]);
			shader_set_2("center",       _cen);
			shader_set_f("gamma",        _gam);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[4], _data[5]);
		_outSurf = channel_apply(_surf, _outSurf, _data[7]);
		
		return _outSurf;
	}
}