#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Glow", "Size > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[2].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Glow", "Mode > Toggle",            "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[10].setValue((_n.inputs[10].getValue() + 1) % 2); });
		addHotkey("Node_Glow", "Side > Toggle",            "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[12].setValue((_n.inputs[12].getValue() + 1) % 2); });
		addHotkey("Node_Glow", "Draw Original > Toggle",   "O", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[11].setValue((_n.inputs[11].getValue() + 1) % 2); });
	});
#endregion

function Node_Glow(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Glow";
	
	newActiveInput(7);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(5, nodeValue_Surface( "Mask"       ));
	newInput(6, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(5, 8); // inputs 8, 9, 
	
	////- =Glow
	newInput(10, nodeValue_Enum_Button( "Mode",  0, [ "Greyscale", "Alpha" ]));
	newInput(12, nodeValue_Enum_Button( "Side",  0, [ "Outer", "Inner" ]));
	newInput( 1, nodeValue_Slider( "Border",     0, [0,  4, .1 ] ));
	newInput( 2, nodeValue_Slider( "Size",       3, [1, 16, .1 ] ));
	newInput( 3, nodeValue_Slider( "Strength",   1, [0,  4, .01] ));
	
	////- =Render
	newInput(13, nodeValue_Enum_Button( "Blend Mode",  3, [ "Normal", "Replace", -1, "Lighten", "Screen", -1, "Darken", "Multiply" ]));
	newInput( 4, nodeValue_Color( "Color",         ca_white ));
	newInput(11, nodeValue_Bool(  "Draw Original", true     ));
	// input 14
		
	input_display_list = [ 7, 
		["Surfaces", true], 0, 5, 6, 8, 9, 
		["Glow",	false], 10, 12, 2, 3,
		["Render",	false], 13, 4, 11, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf     = _data[ 0];
		
		var _mode     = _data[10];
		var _side     = _data[12];
		var _border   = _data[ 1];
		var _size     = _data[ 2];
		var _strength = _data[ 3];
		
		var _blend    = _data[13];
		var _color    = _data[ 4];
		var _render   = _data[11];
		
		inputs[13].setVisible(_mode == 0);
		
		surface_set_shader(_outSurf, sh_glow);
			shader_set_dim("dimension", _surf);
			
			shader_set_i("mode",      _mode);
			shader_set_i("side",      _side);
			shader_set_f("border",    _border);
			shader_set_f("size",      _size);
			shader_set_f("strength",  _strength);
			
			shader_set_i("blend",     _blend);
			shader_set_color("color", _color);
			shader_set_i("render",    _render);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[5], _data[6]);
		
		return _outSurf;
	}
}