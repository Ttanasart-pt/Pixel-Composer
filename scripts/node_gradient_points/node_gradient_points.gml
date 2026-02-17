function Node_Gradient_Points(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw 4 Points Gradient";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput(17, nodeValue_Surface( "UV Map"     ));
	newInput(18, nodeValue_Slider(  "UV Mix", 1  ));
	
	////- =Positions
	newInput(1, nodeValue_Vec2( "Center 1", [0,0] )).setUnitSimple();
	newInput(3, nodeValue_Vec2( "Center 2", [1,0] )).setUnitSimple();
	newInput(5, nodeValue_Vec2( "Center 3", [0,1] )).setUnitSimple();
	newInput(7, nodeValue_Vec2( "Center 4", [1,1] )).setUnitSimple();
	
	////- =Falloff
	newInput(11, nodeValue_Slider( "Falloff 1", 6, [ 0, 32, 0.1 ] ));
	newInput(12, nodeValue_Slider( "Falloff 2", 6, [ 0, 32, 0.1 ] ));
	newInput(13, nodeValue_Slider( "Falloff 3", 6, [ 0, 32, 0.1 ] ));
	newInput(14, nodeValue_Slider( "Falloff 4", 6, [ 0, 32, 0.1 ] ));
	newInput(15, nodeValue_Bool(   "Normalize weight", true      ))
	
	////- =Colors
	newInput( 9, nodeValue_Bool(    "Use palette", false ));
	newInput(10, nodeValue_Palette( "Palette"            ));
	newInput( 2, nodeValue_Color(   "Color 1",  ca_white ));
	newInput( 4, nodeValue_Color(   "Color 2",  ca_white ));
	newInput( 6, nodeValue_Color(   "Color 3",  ca_white ));
	newInput( 8, nodeValue_Color(   "Color 4",  ca_white ));
	newInput(16, nodeValue_EButton( "Color Space", 0, [ "RGB", "OKLAB" ] ));
	// 19
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		[ "Output",    true  ],  0, 17, 18, 
		[ "Positions", false ],  1,  3,  5,  7,
		[ "Falloff",   true  ], 11, 12, 13, 14, 15, 
		[ "Colors",    false ],  9, 10,  2,  4,  6,  8, 16, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[7].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim = _data[0];
			
			var _usePal = _data[9];
			var _pal    = _data[10];
			
			var _1cen = _data[1], _1col = _data[2];
			var _2cen = _data[3], _2col = _data[4];
			var _3cen = _data[5], _3col = _data[6];
			var _4cen = _data[7], _4col = _data[8];
			
			var _1str = _data[11];
			var _2str = _data[12];
			var _3str = _data[13];
			var _4str = _data[14];
			
			var _blnd = _data[15];
			var _cspc = _data[16];
			
			inputs[10].setVisible(_usePal, _usePal);
			
			inputs[ 2].setVisible(!_usePal, !_usePal);
			inputs[ 4].setVisible(!_usePal, !_usePal);
			inputs[ 6].setVisible(!_usePal, !_usePal);
			inputs[ 8].setVisible(!_usePal, !_usePal);
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		var colArr = [];
		
		if(_usePal) {
			colArr = array_append(colArr, colorToArray(array_safe_get_fast(_pal, 0, c_black), 1));
			colArr = array_append(colArr, colorToArray(array_safe_get_fast(_pal, 1, c_black), 1));
			colArr = array_append(colArr, colorToArray(array_safe_get_fast(_pal, 2, c_black), 1));
			colArr = array_append(colArr, colorToArray(array_safe_get_fast(_pal, 3, c_black), 1));
			
		} else {
			colArr = array_append(colArr, colorToArray(_1col, 1));
			colArr = array_append(colArr, colorToArray(_2col, 1));
			colArr = array_append(colArr, colorToArray(_3col, 1));
			colArr = array_append(colArr, colorToArray(_4col, 1));
		}
		
		surface_set_shader(_outSurf, sh_gradient_points);
			shader_set_uv(_data[17], _data[18]);
			
			shader_set_f("dimension", _dim);
			shader_set_f("center",    [
				_1cen[0], _1cen[1], 
				_2cen[0], _2cen[1], 
				_3cen[0], _3cen[1], 
				_4cen[0], _4cen[1]
			]);
			
			shader_set_f("strength",  [ _1str, _2str, _3str, _4str ]);
			shader_set_f("color",     colArr);
			shader_set_i("blend",     _blnd);
			shader_set_i("cspace",    _cspc);
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
}
