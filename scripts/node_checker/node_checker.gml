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
	newInput( 9, nodeValue_Bool(     "Diagonal",  false  ));
	newInput( 1, nodeValue_Float(    "Amount",   .5      )).setMappable(6).setUnitSimple();
	newInput(13, nodeValue_Float(    "Aspect",    1      ));
	newInput( 2, nodeValue_Rotation( "Angle",     0      )).setHotkey("R").setMappable(7);
	newInput( 3, nodeValue_Vec2(     "Position", [.5,.5] )).setHotkey("G").setUnitSimple();
	
	////- =Render
	newInput( 8, nodeValue_EButton( "Type",    0, [ "Solid", "Smooth", "AA" ] ));
	newInput( 4, nodeValue_Color(   "Color 1", ca_white ));
	newInput( 5, nodeValue_Color(   "Color 2", ca_black ));
	// input 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		[ "Output",	  true ],  0, 11, 12, 10, 
		[ "Pattern", false ],  9,  1,  6, 13,  2,  7,  3,
		[ "Render",  false ],  8,  4,  5,
	];
	
	input_display_deco = function(_x, _y, _w, _m, _hover, _focus, _panel) /*=>*/ {
		if(_panel.viewMode != INSP_VIEW_MODE.compact) return;
		
		var c1 = inputs[4];
		var c2 = inputs[5];
		if(!c1.visible_in_inspector || !c2.visible_in_inspector) return;
		
		var bs = ui(20);
		
		var y1 = c1.inspector_y;
		var y2 = c2.inspector_y + c2.inspector_h;
		
		var bx = c1.inspector_x - ui(4) - bs;
		var by = (y1 + y2) / 2 - bs / 2;
		
		if(buttonInstant_Pad(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, "Swap", THEME.swap_vert, 0,, 1, ui(6)) == 2)
			juncSwap(c1, c2);
	};
	
	////- Nodes
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var pos = getInputData(3);
		var rot = getInputData(2);
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my            ));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my            ));
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, rot, 1, 2 ));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim = _data[ 0];
			
			var _dia = _data[ 9];
			var _asp = _data[13];
			var _pos = _data[ 3];
			
			var _bld = _data[ 8];
			var _c1  = _data[ 4];
			var _c2  = _data[ 5];
		
			inputs[2].setVisible(!_data[9]);
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_checkerboard);
			shader_set_uv(_data[11], _data[12]);
			
			shader_set_2( "dimension",  _dim );
			
			shader_set_i( "diagonal",   _dia );
			shader_set_f( "position",   _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f_map( "amount", _data[1], _data[6], inputs[1]);
			shader_set_f_map( "angle",  _data[2], _data[7], inputs[2]);
			shader_set_f( "aspect",     _asp );
			
			shader_set_i( "blend",      _bld );
			shader_set_c( "col1",       _c1  );
			shader_set_c( "col2",       _c2  );
			
			draw_empty();
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}