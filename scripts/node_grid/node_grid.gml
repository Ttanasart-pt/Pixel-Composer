#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Grid", "Render Type > Toggle", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[10].setValue((_n.inputs[10].getValue() + 1) % 5); });
	});
#endregion

function Node_Grid(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grid";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput(37, nodeValue_Surface( "UV Map"     ));
	newInput(38, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(35, nodeValue_Surface( "Mask"       ));
	
	////- =Pattern
	newInput( 1, nodeValue_Vec2(     "Position",      [0,0]     )).setHotkey("G").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, UNIT_REF);
	newInput( 4, nodeValue_Rotation( "Angle",          0        )).setHotkey("R").setMappable(15);
	newInput(36, nodeValue_Bool(     "Invert Size",    false    ));
	newInput( 2, nodeValue_Vec2(     "Grid Size",     [.25,.25] )).setHotkey("S").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, UNIT_REF).setMappable(13);
	newInput(28, nodeValue_Bool(     "Uniform Gap",    true     ));
	newInput(26, nodeValue_Float(    "Gap Width",      1        ));
	newInput(27, nodeValue_Bool(     "Diagonal",       false    ));
	newInput( 3, nodeValue_Slider(   "Gap",           .2, [0, 0.5, 0.001] )).setMappable(14);
	
	////- =Shift
	newInput( 9, nodeValue_Enum_Button(          "Shift Axis",      0, ["X", "Y"] ));
	newInput( 8, nodeValue_Slider(               "Shift",           0, [-0.5, 0.5, 0.01] )).setMappable(16);
	newInput(31, nodeValue_Slider(               "Random Shift",    0 ));
	newInput(32, nodeValueSeed(VALUE_TYPE.float, "Shift Seed"         ));
	newInput(30, nodeValue_Slider(               "Secondary Shift", 0 ));
	
	////- =Scale
	newInput(33, nodeValue_Slider(               "Random Scale", 0    ));
	newInput(34, nodeValueSeed(VALUE_TYPE.float, "Scale Seed"         ));
	newInput(29, nodeValue_Float(                "Secondary Scale", 0 ));
	
	////- =Render
	newInput(10, nodeValue_Enum_Scroll( "Render Type",  0, ["Colored tile", "Colored tile (Accurate)", "Height map", "Texture grid", "Texture sample"]));
	newInput(11, nodeValueSeed());
	newInput( 5, nodeValue_Gradient(     "Tile Color", new gradientObject(ca_white))).setMappable(20);
	newInput( 6, nodeValue_Color(        "Gap Color",  ca_black ));
	newInput( 7, nodeValue_Surface(      "Texture" ));
	newInput(25, nodeValue_Bool(         "Use Texture Dimension", false ));
	newInput(12, nodeValue_Bool(         "Anti-aliasing",         false ));
	newInput(24, nodeValue_Slider_Range( "Level",                 [0,1] ));
	
	////- =Truchet
	newInput(17, nodeValue_Bool(           "Truchet",         false ));
	newInput(18, nodeValue_Int(            "Truchet Seed",    seed_random()));
	newInput(19, nodeValue_Slider(         "Flip Horizontal", .5    ));
	newInput(22, nodeValue_Slider(         "Flip Vertical",   .5    ));
	newInput(23, nodeValue_Rotation_Range( "Texture Angle",   [0,0] ));
	// input 39
	
	input_display_list = [
		[ "Output",  false     ],  0, 37, 38, 35, 
		[ "Pattern", false     ],  1,  4, 15, 36,  2, 13, 28,  3, 26, 27, 14, 
		[ "Shift",   false     ],  9,  8, 16, 31, 32, 30, 
		[ "Scale",   false     ], 33, 34, 29, 
		[ "Render",  false     ], 10, 11,  5, 20,  6,  7, 25, 12, 24, 
		[ "Truchet",  true, 17 ], 18, 19, 22, 23, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_interpolation();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var pos = getSingleValue(1);
		var rot = getSingleValue(4);
		
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny                    ));
		InputDrawOverlay(inputs[ 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny, 1, [1,1], rot     ));
		InputDrawOverlay(inputs[ 4].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny                    ));
		InputDrawOverlay(inputs[21].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, getSingleValue(0) ));
		
		return w_hovering;
	}
	
	static getDimension = function(_arr = 0) {
		var _dim = getSingleValue( 0, _arr);
		var _sam = getSingleValue( 7, _arr);
		var _mod = getSingleValue(10, _arr);
		var _txd = getSingleValue(25, _arr);
		var _tex = _mod == 3 || _mod == 4;
		
		if(is_surface(_sam) && _tex && _txd) 
			return surface_get_dimension(_sam);
		return _dim;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim  = surface_get_dimension(_outSurf);
		var _pos  = _data[ 1];
		var _sam  = _data[ 7];
		var _mode = _data[10];
		
		var _col_gap  = _data[6];
		var _tex_mode = _mode == 3 || _mode == 4;
		
		inputs[ 5].setVisible(_mode == 0 || _mode == 1);
		inputs[ 3].setVisible(_mode == 0 || _mode == 3 || _mode == 4);
		inputs[24].setVisible(_mode == 2);
		inputs[26].setVisible(_mode == 1);
		
		inputs[ 4].setVisible(_mode != 1);
		inputs[ 8].setVisible(_mode != 1);
		inputs[ 9].setVisible(_mode != 1);
		inputs[27].setVisible(_mode == 1);
		
		inputs[ 7].setVisible(_tex_mode, _tex_mode);
		inputs[25].setVisible(_tex_mode, _tex_mode);
		
		surface_set_shader(_outSurf, sh_grid);
			shader_set_uv(_data[37], _data[38]);
		    shader_set_interpolation(_sam);
		    
			shader_set_f("position",	_pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f("dimension",	_dim[0], _dim[1]);
			
			shader_set_f_map("scale",	_data[ 2], _data[13], inputs[2]);
			shader_set_f_map("width",	_data[ 3], _data[14], inputs[3]);
			shader_set_f_map("angle",	_data[ 4], _data[15], inputs[4]);
			shader_set_f_map("shift",	_data[ 8], _data[16], inputs[8]);
			
			shader_set_i("mode",           _mode);
			shader_set_i("scaleMode",      _data[36]);
			shader_set_f("seed",           _data[11]);
			shader_set_i("shiftAxis",      _data[ 9]);
			shader_set_i("aa",             _data[12]);
			shader_set_i("textureTruchet", _data[17]);
			shader_set_f("truchetSeed",    _data[18]);
			shader_set_f("truchetThresX",  _data[19]);
			shader_set_f("truchetThresY",  _data[22]);
			shader_set_2("truchetAngle",   _data[23]);
			shader_set_2("level",          _data[24]);
			shader_set_f("gapAcc",         _data[26]);
			shader_set_i("diagonal",       _data[27]);
			shader_set_i("uniformSize",    _data[28]);
			shader_set_f("secScale",       _data[29]);
			shader_set_f("secShift",       _data[30]);
			
			shader_set_f("randShift",      _data[31]);
			shader_set_f("randShiftSeed",  _data[32]);
			shader_set_f("randScale",      _data[33]);
			shader_set_f("randScaleSeed",  _data[34]);
			
			shader_set_color("gapCol", _col_gap);
			
			shader_set_gradient(_data[5], _data[20], _data[21], inputs[5]);
			
			if(is_surface(_sam))	draw_surface_stretched_safe(_sam, 0, 0, _dim[0], _dim[1]);
			else					draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}