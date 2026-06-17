#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Stripe", "Amount > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Stripe", "Type > Toggle",      "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 1) % 3); });
		addHotkey("Node_Stripe", "Coloring > Toggle",  "C", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[6].setValue((_n.inputs[6].getValue() + 1) % 3); });
		addHotkey("Node_Stripe", "Angle > Rotate CCW", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 90) % 360); });
	});
#endregion

function Node_Stripe(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Stripe";
	
	newInput(19, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput(21, nodeValue_Surface(  "UV Map"     ));
	newInput(22, nodeValue_Slider(   "UV Mix", 1  ));
	newInput(20, nodeValue_Surface(  "Mask"       ));
	
	////- =Pattern
	newInput(23, nodeValue_Bool(     "Tiled"                ));
	newInput( 1, nodeValue_Slider(   "Size",         .25    )).setUnitSimple().setMappable(11).setHotkey("S").setPieMenu();
	newInput(24, nodeValue_Slider(   "Amount",       .25    ))                                                            ;
	newInput(10, nodeValue_Slider(   "Strip Ratio",  .5     ))                .setMappable(14)               .setPieMenu();
	newInput( 2, nodeValue_Rotation( "Angle",         0     ))                .setMappable(12).setHotkey("R").setPieMenu();
	newInput( 4, nodeValue_Vec2(     "Position",    [.5,.5] )).setUnitSimple()                .setHotkey("G")             ;
	newInput( 5, nodeValue_Slider(   "Random",        0     ))                .setMappable(13)                            ;
	newInput(17, nodeValue_Slider(   "Progress",     .5     ))                                               .setPieMenu();
	
	////- =Render
	newInput( 3, nodeValue_EButton(  "Type",      0, [ "Solid", "Smooth", "AA" ] ));
	newInput( 6, nodeValue_EButton(  "Coloring",  0, [ "Alternate", "Palette", "Random" ] ));
	newInput( 7, nodeValue_Gradient( "Colors",    gra_white )).setMappable(15);
	newInput( 8, nodeValue_Color(    "Color 1",   ca_white  ));
	newInput( 9, nodeValue_Color(    "Color 2",   ca_black  ));
	newInput(18, nodeValue_Palette(  "Colors",   [ca_black,ca_white] ));
	// 25
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 19, 
		[ "Output",   true ],  0, 21, 22, 20, 
		[ "Pattern", false ],  1, 24, 11, 10, 14,  2, 12,  4,  5, 13, 17, 
		[ "Render",  false ],  3,  6,  7, 15,  8,  9, 18, 
	];
	
	input_display_deco = function(_x, _y, _w, _m, _hover, _focus, _panel) /*=>*/ {
		if(_panel.viewMode != INSP_VIEW_MODE.compact) return;
		
		var c1 = inputs[8];
		var c2 = inputs[9];
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
		PROCESSOR_OVERLAY_CHECK
		
		var rot = current_data[2];
		var pos = current_data[4];
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[ 4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my ));
		InputDrawOverlay(inputs[ 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my ));
		InputDrawOverlay(inputs[ 1].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, rot, 1, 2       ));
		InputDrawOverlay(inputs[16].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, current_data[0] ));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _seed = _data[19];
			
			var _dim  = _data[ 0];
			
			var _tile = _data[23];
			var _amo  = _data[ 1];
			var _tamo = _data[24];
			
			var _rat  = _data[10];
			var _ang  = _data[ 2];
			var _pos  = _data[ 4];
			var _ran  = _data[ 5];
			var _prg  = _data[17];
			
			var _bnd  = _data[ 3];
			var _col  = _data[ 6];
			var _clr0 = _data[ 8];
			var _clr1 = _data[ 9];
			var _pal  = _data[18];
			
			inputs[ 1].setVisible(!_tile);
			inputs[24].setVisible( _tile);
			inputs[ 2].setVisible(!_tile);
			
			inputs[ 8].setVisible(_col == 0);
			inputs[ 9].setVisible(_col == 0);
			inputs[18].setVisible(_col == 1);
			inputs[ 7].setVisible(_col == 2);
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		surface_set_shader(_outSurf, sh_stripe);
			shader_set_uv(_data[21], _data[22]);
			
			shader_set_f( "seed",      _seed );
			shader_set_f( "dimension", _dim[0], _dim[1] );
			shader_set_f( "position",  _pos[0] / _dim[0], _pos[1] / _dim[1] );
			shader_set_i( "blend",     _bnd );
			shader_set_f( "progress",  _prg );
			
			shader_set_i(     "tiled",        _tile );
			shader_set_f(     "tiledAmo",     _tamo );
			shader_set_f_map( "amount",       _amo, _data[11], inputs[ 1] );
			shader_set_f_map( "ratio",        _rat, _data[14], inputs[10] );
			shader_set_f_map( "angle",        _ang, _data[12], inputs[ 2] );
			shader_set_f_map( "randomAmount", _ran, _data[13], inputs[ 5] );
			
			shader_set_i( "coloring", _col  );
			shader_set_c( "color0",   _clr0 );
			shader_set_c( "color1",   _clr1 );
			shader_set_palette(_pal);
			shader_set_gradient(_data[7], _data[15], _data[16], inputs[7]);
			
			draw_empty();
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}

}