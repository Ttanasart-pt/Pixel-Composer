function Node_Perlin_Smear(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Smear noise";
	
	////- =Output
	newInput(0, nodeValue_Dimension());
	newInput(6, nodeValue_Surface(  "Mask"));
	
	////- =Noise
	newInput(1, nodeValue_Vec2(     "Position",   [0,0] )).setHotkey("G").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput(5, nodeValue_Rotation( "Rotation",    0    )).setHotkey("R");
	newInput(2, nodeValue_Vec2(     "Scale",      [4,6] )).setHotkey("S");
	newInput(3, nodeValue_Int(      "Iteration",   3    ));
	newInput(4, nodeValue_Slider(   "Brightness", .5    ));
	// input 7
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Output", false], 0, 6, 
		["Noise",  false], 1, 5, 2, 3, 4,
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pos = getSingleValue(1);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		var _ite = _data[3];
		var _bri = _data[4];
		var _rot = _data[5];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_perlin_smear);
			shader_set_f("dimension", _dim);
			shader_set_2("position",  _pos);
			shader_set_2("scale",	  _sca);
			shader_set_f("bright",	  _bri);
			shader_set_i("iteration", _ite);
			shader_set_f("rotation",  degtorad(_rot));
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}