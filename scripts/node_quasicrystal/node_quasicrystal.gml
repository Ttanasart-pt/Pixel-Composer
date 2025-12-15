function Node_Quasicrystal(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Quasicrystal";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput(12, nodeValue_Surface( "UV Map"     ));
	newInput(13, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(11, nodeValue_Surface( "Mask" ));
	
	////- =Pattern
	newInput( 3, nodeValue_Vec2(      "Position", [.5,.5] )).setHotkey("G").setUnitSimple();
	newInput( 2, nodeValue_Rotation(  "Angle",      0     )).setHotkey("R").setMappable(7);
	newInput( 1, nodeValue_Slider(    "Scale",     .25    )).setHotkey("S").setMappable(6).setUnitSimple();
	newInput( 8, nodeValue_Slider(    "Phase",      0     )).setMappable(9);
	newInput(10, nodeValue_Rotation_Range( "Angle Range", [0,180] ));
	
	////- =Colors
	newInput( 4, nodeValue_Color( "Color 1", ca_white));
	newInput( 5, nodeValue_Color( "Color 2", ca_black));
	// input 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		["Output",	 true],	0, 12, 13, 11, 
		["Pattern",	false], 3, 2, 7, 1, 6, 8, 9, 10, 
		["Colors",  false], 4, 5, 
	];
	
	attribute_surface_depth();
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var rot  = getInputData(2);
		var pos  = getInputData(3);
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny            ));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny            ));
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny, rot, 1, 2 ));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim  = _data[ 0];
		var _fre  = _data[ 1];
		var _ang  = _data[ 2];
		var _pos  = _data[ 3];
		var _clr0 = _data[ 4];
		var _clr1 = _data[ 5];
		var _aran = _data[10];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			
		surface_set_shader(_outSurf, sh_quarsicrystal);
			shader_set_uv(_data[12], _data[13]);
			shader_set_f("dimension",	 _dim[0], _dim[1]);
			shader_set_f("position",	 _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_2("rangleRange",	 _aran);
			
			shader_set_f_map("amount",	_data[1], _data[6], inputs[ 1]);
			shader_set_f_map("angle",	_data[2], _data[7], inputs[ 2]);
			shader_set_f_map("phase",	_data[8], _data[9], inputs[ 8]);
			
			shader_set_color("color0", _clr0);
			shader_set_color("color1", _clr1);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}