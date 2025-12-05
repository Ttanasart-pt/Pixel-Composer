#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Grid_Tri", "Render Type > Toggle", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[8].setValue((_n.inputs[8].getValue() + 1) % 4); });
	});
#endregion

function Node_Grid_Tri(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Triangle Grid";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput(23, nodeValue_Surface( "UV Map"     ));
	newInput(24, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(22, nodeValue_Surface( "Mask" ));
	
	////- =Pattern
	newInput( 1, nodeValue_Vec2(     "Position", [.5,.5]   )).setHotkey("G").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, UNIT_REF);
	newInput( 4, nodeValue_Rotation( "Angle",     0        )).setHotkey("R").setMappable(13);
	newInput( 2, nodeValue_Vec2(     "Scale",    [.25,.25] )).setHotkey("S").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, UNIT_REF).setMappable(11);
	newInput( 3, nodeValue_Slider(   "Gap",      .1, [0, 0.5, 0.001] )).setMappable(12);
	
	////- =Render
	newInput( 8, nodeValue_Enum_Scroll( "Render Type",  0, ["Colored tile", "Height map", "Texture grid", "Texture sample"]));
	newInput( 9, nodeValueSeed());
	newInput( 5, nodeValue_Gradient(     "Tile Color", new gradientObject(ca_white) )).setMappable(17);
	newInput( 6, nodeValue_Color(        "Gap Color",  ca_black ));
	newInput( 7, nodeValue_Surface(      "Texture" ));
	newInput(21, nodeValue_Bool(         "Use Texture Dimension", false ));
	newInput(10, nodeValue_Bool(         "Anti-aliasing",         false ));
	newInput(20, nodeValue_Slider_Range( "Level",                 [0,1] ));
	
	////- =Truchet
	newInput(14, nodeValue_Bool(           "Truchet",           false         ));
	newInput(15, nodeValue_Int(            "Truchet Seed",      seed_random() ));
	newInput(16, nodeValue_Slider(         "Truchet Threshold", .5            ));
	newInput(19, nodeValue_Rotation_Range( "Texture Angle",     [0,0]         ));
	// input 23
	
	input_display_list = [
		["Output",  false], 0, 23, 24, 22, 
		["Pattern",	false], 1, 4, 13, 2, 11, 3, 12, 
		["Render",	false], 8, 9, 5, 17, 6, 7, 21, 10, 20, 
		["Truchet",  true, 14], 15, 16, 19, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_interpolation();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _dim = getDimension();
		var _pos = getSingleValue(1);
		var _rot = getSingleValue(4);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny                           ));
		InputDrawOverlay(inputs[ 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny, 1, [1.5,sqrt(3)/2], _rot ));
		InputDrawOverlay(inputs[ 4].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny                           ));
		InputDrawOverlay(inputs[18].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, getSingleValue(0)        ));
		
		return w_hovering;
	}
	
	static getDimension = function(_arr = 0) {
		var _dim = getSingleValue( 0, _arr);
		var _sam = getSingleValue( 7, _arr);
		var _mod = getSingleValue( 8, _arr);
		var _txd = getSingleValue(21, _arr);
		var _tex = _mod == 3 || _mod == 4;
		
		if(is_surface(_sam) && _tex && _txd) 
			return surface_get_dimension(_sam);
		return _dim;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim  = surface_get_dimension(_outSurf);
		var _pos  = _data[1];
		var _sam  = _data[7];
		var _mode = _data[8];
		var _sed  = _data[9];
		var _aa   = _data[10];
		
		var _col_gap  = _data[6];
		var _tex_mode = _mode == 2 || _mode == 3;
		
		inputs[ 5].setVisible(_mode == 0);
		inputs[ 6].setVisible(_mode != 1);
		inputs[20].setVisible(_mode == 1);
		
		inputs[ 7].setVisible(_tex_mode, _tex_mode);
		inputs[21].setVisible(_tex_mode, _tex_mode);
		
		surface_set_shader(_outSurf, sh_grid_tri);
			shader_set_uv(_data[23], _data[24]);
		    shader_set_interpolation(_sam);
		    
			shader_set_f("position",  _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f("dimension", _dim[0], _dim[1]);
			
			shader_set_f_map("scale", _data[2], _data[11], inputs[2]);
			shader_set_f_map("width", _data[3], _data[12], inputs[3]);
			shader_set_f_map("angle", _data[4], _data[13], inputs[4]);
			
			shader_set_f("seed",      _sed);
			shader_set_i("mode",      _mode);
			shader_set_i("aa",        _aa);
			shader_set_color("gapCol",_col_gap);
			
			shader_set_i("textureTruchet", _data[14]);
			shader_set_f("truchetSeed",    _data[15]);
			shader_set_f("truchetThres",   _data[16]);
			shader_set_2("truchetAngle",   _data[19]);
			shader_set_2("level",          _data[20]);
			
			shader_set_gradient(_data[5], _data[17], _data[18], inputs[5]);
			
			if(is_surface(_sam))	draw_surface_stretched_safe(_sam, 0, 0, _dim[0], _dim[1]);
			else					draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}