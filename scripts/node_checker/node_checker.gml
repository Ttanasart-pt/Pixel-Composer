#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Checker", "Amount > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Checker", "Diagonal > Toggle", "D", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue(!_n.inputs[9].getValue());          });
		addHotkey("Node_Checker", "Type > Toggle",     "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[8].setValue((_n.inputs[8].getValue() + 1) % 3); });
	});
#endregion

function Node_Checker(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Checker";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput(11, nodeValue_Surface( "UV Map"     ));
	newInput(12, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(10, nodeValue_Surface( "Mask" ));
	
	////- =Pattern
	newInput(9, nodeValue_Bool(     "Diagonal",  false  ));
	newInput(1, nodeValue_Slider(   "Amount",   .5,     )).setMappable(6).setUnitSimple();
	newInput(2, nodeValue_Rotation( "Angle",     0      )).setHotkey("R").setMappable(7);
	newInput(3, nodeValue_Vec2(     "Position", [.5,.5] )).setHotkey("G").setUnitSimple();
	
	////- =Render
	newInput(8, nodeValue_Enum_Button( "Type",    0, [ "Solid", "Smooth", "AA" ] ));
	newInput(4, nodeValue_Color(       "Color 1", ca_white ));
	newInput(5, nodeValue_Color(       "Color 2", ca_black ));
	// input 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Output",	true],	0, 11, 12, 10, 
		["Pattern",	false], 9, 1, 6, 2, 7, 3,
		["Render",	false], 8, 4, 5,
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var pos = getInputData(3);
		var rot = getInputData(2);
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny            ));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny            ));
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny, rot, 1, 2 ));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim = _data[0];
		var _pos = _data[3]
		
		inputs[2].setVisible(!_data[9]);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_checkerboard);
			shader_set_uv(_data[11], _data[12]);
			
			shader_set_2("dimension",  _dim);
			shader_set_i("diagonal",   _data[9]);
			shader_set_f("position",   _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f_map("amount", _data[1], _data[6], inputs[1]);
			shader_set_f_map("angle",  _data[2], _data[7], inputs[2]);
			shader_set_color("col1",   _data[4]);
			shader_set_color("col2",   _data[5]);
			shader_set_i("blend",      _data[8]);
			
			draw_empty();
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}