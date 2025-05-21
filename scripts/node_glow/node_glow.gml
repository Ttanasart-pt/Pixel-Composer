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
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Float("Border", 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 4, 0.1] });
	
	newInput(2, nodeValue_Float("Size", 3))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	newInput(3, nodeValue_Float("Strength", 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ]});
	
	newInput(4, nodeValue_Color("Color", ca_white));
	
	newInput(5, nodeValue_Surface("Mask"));
	
	newInput(6, nodeValue_Float("Mix", 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(7, nodeValue_Bool("Active", true));
		active_index = 7;
	
	__init_mask_modifier(5); // inputs 8, 9, 
	
	newInput(10, nodeValue_Enum_Button("Mode",  0, [ "Greyscale", "Alpha" ]));
		
	newInput(11, nodeValue_Bool("Draw Original", true));
	
	newInput(12, nodeValue_Enum_Button("Side",  0, [ "Outer", "Inner" ]));
		
	input_display_list = [ 7, 
		["Surfaces", true], 0, 5, 6, 8, 9, 
		["Glow",	false], 10, 12, 2, 3,
		["Render",	false], 4, 11, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		var _border   = _data[1];
		var _size     = _data[2];
		var _strength = _data[3];
		var _color    = _data[4];
		var _mode     = _data[10];
		var _render   = _data[11];
		var _side     = _data[12];
		
		surface_set_shader(_outSurf, sh_glow);
			shader_set_dim("dimension", _data[0]);
			shader_set_i("mode",      _mode);
			shader_set_f("border",    _border);
			shader_set_f("size",      _size);
			shader_set_f("strength",  _strength);
			shader_set_color("color", _color);
			shader_set_i("render",    _render);
			shader_set_i("side",      _side);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		
		return _outSurf;
	}
}