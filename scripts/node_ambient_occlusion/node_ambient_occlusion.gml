function Node_Ambient_Occlusion(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Ambient Occlusion";
	
	newActiveInput(2);
	newInput(0, nodeValue_Surface("Height Map"));
	
	////- =Effect
	newInput(3, nodeValue_Float(  "Height",     .25   )).setMappable(9).setUnitSimple();
	newInput(1, nodeValue_Slider( "Intensity",   4, [ 0, 8, 0.1 ] )).setMappable(8).setCurvable(10);
	newInput(4, nodeValue_Bool(   "Pixel Sweep", true ));
	
	////- =Blend
	newInput(5, nodeValue_Bool(    "Blend Original", false ));
	newInput(6, nodeValue_EScroll( "Blendmode",      0, [ "Multiply", "Subtract" ] ));
	newInput(7, nodeValue_Slider(  "Blend Strength", 1     ));
	// 11
	
	input_display_list = [ 2, 0, 
		[ "Effect",         false    ], 3, 9, 1, 8, 10, 4, 
		[ "Blend Original", false, 5 ], 6, 7, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[ 1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my,  90, _dim[1] / 16 ));
		InputDrawOverlay(inputs[ 3].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my,   0, 1 ));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _map = _data[0];
			var _int = _data[1];
			var _hei = _data[3];
			var _pxs = _data[4];
			
			var _bl  = _data[5];
			var _blm = _data[6];
			var _bls = _data[7];
		#endregion
		
		surface_set_shader(_outSurf, sh_sao);
			shader_set_interpolation(_map);
			shader_set_dim("dimension",   _map);
			shader_set_f_map("intensity", _int, _data[8], inputs[1], _data[10]);
			shader_set_f_map("height",    _hei, _data[9], inputs[3]);
			shader_set_i("pixel",         _pxs);
			
			shader_set_i("blend",         _bl);
			shader_set_i("blendMode",     _blm);
			shader_set_f("blendStrength", _bls);
			
			draw_surface_safe(_map);
		surface_reset_shader();
		
		return _outSurf;
	}
}