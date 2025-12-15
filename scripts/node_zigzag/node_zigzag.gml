#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Zigzag", "Amount > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Zigzag", "Type > Toggle",              "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[5].setValue((_n.inputs[5].getValue() + 1) % 3); });
	});
#endregion

function Node_Zigzag(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Zigzag";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput(11, nodeValue_Surface( "UV Map"     ));
	newInput(12, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 9, nodeValue_Surface( "Mask"       ));
	
	////- =Pattern
	newInput( 1, nodeValue_Slider(   "Amount",      1     )).setUnitSimple().setMappable(6);
	newInput( 2, nodeValue_Vec2(     "Position",  [.5,.5] )).setHotkey("G").setUnitSimple();
	newInput( 8, nodeValue_Rotation( "Angle",       0     )).setHotkey("R").setMappable(7);
	newInput(10, nodeValue_Slider(   "Threshold",  .5     ));
	
	////- =Render
	newInput( 5, nodeValue_Enum_Button( "Type",    0, [ "Solid", "Smooth", "AA" ]));
	newInput( 3, nodeValue_Color(       "Color 1", ca_white));
	newInput( 4, nodeValue_Color(       "Color 2", ca_black));
	// input 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Output",  false], 0, 11, 12, 9, 
		["Pattern",	false], 1, 6, 2, 8, 10,  
		["Render",	false], 5, 3, 4, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var pos = current_data[2];
		var rot = current_data[8];
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny ));
		InputDrawOverlay(inputs[8].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny ));
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny, rot, 1, 2 ));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim = _data[0];
		var _pos = _data[2];
		
		var _col1 = _data[3];
		var _col2 = _data[4];
		var _bnd  = _data[5];
		var _thr  = _data[10];
		
		inputs[10].setVisible(_bnd != 1);
		
		surface_set_shader(_outSurf, sh_zigzag);
			shader_set_uv(_data[11], _data[12]);
			
			shader_set_f("dimension",   _dim);
			shader_set_f("position",   _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f_map("amount", _data[1], _data[6], inputs[1]);
			shader_set_f_map("angle",  _data[8], _data[7], inputs[8]);
			shader_set_i("blend",      _bnd);
			shader_set_color("col1",   _col1);
			shader_set_color("col2",   _col2);
			shader_set_f("threshold",  _thr);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}