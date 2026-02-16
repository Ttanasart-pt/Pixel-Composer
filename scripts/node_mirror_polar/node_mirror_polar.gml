#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Mirror_Polar", "Spokes > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[4].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Mirror_Polar", "Angle > Rotate CCW",  "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 90) % 360); });
		addHotkey("Node_Mirror_Polar", "Reflective > Toggle", "F", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[5].setValue((_n.inputs[5].getValue() + 1) % 2); });
	});
#endregion

function Node_Mirror_Polar(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Polar Mirror";
	
	newActiveInput(3);
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface(     "Surface In" ));
	newInput( 7, nodeValue_Enum_Scroll( "Output Dimension",     0, [ "Same as input", "Relative", "Constant" ] ));
	newInput( 8, nodeValue_Vec2(        "Relative Dimension",  [1,1]    ));
	newInput( 9, nodeValue_Vec2(        "Constant Dimension",  DEF_SURF ));
	
	////- =Mirror
	newInput( 1, nodeValue_Vec2(        "Position",    [.5,.5] )).setHotkey("G").setUnitSimple();
	newInput( 2, nodeValue_Rotation(    "Angle",         0     )).setHotkey("R");
	newInput( 6, nodeValue_Vec2(        "Scale",        [1,1]  ));
	newInput(10, nodeValue_Enum_Scroll( "Radial Scale",  0, [ "Linear", "Exponential" ] ));
	newInput(13, nodeValue_Float(       "Trim Radius",   0 ));
	
	////- =Spokes
	newInput( 4, nodeValue_Float( "Spokes",     4     )).setMappable(11).setCurvable(12);
	newInput( 5, nodeValue_Bool(  "Reflective", false ));
	// 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3,
		[ "Surfaces", false ],  0,  7,  8,  9, 
		[ "Mirror",   false ],  1,  2,  6, 10, 13, 
		[ "Spokes",   false ],  4, 11, 12,  5, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _pos   = current_data[1];
		var _ang   = current_data[2];
		var _posx = _pos[0] * _s + _x;
		var _posy = _pos[1] * _s + _y;
		
		var dx0 = _posx + lengthdir_x(1000, _ang);
		var dx1 = _posx + lengthdir_x(1000, _ang + 180);
		var dy0 = _posy + lengthdir_y(1000, _ang);
		var dy1 = _posy + lengthdir_y(1000, _ang + 180);
		
		draw_set_color(COLORS._main_accent);
		draw_line(dx0, dy0, dx1, dy1);
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _posx, _posy, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static getDimension = function(arr = 0) { 
		var _surf = getInputSingle(0, arr);
		var _outt = getInputSingle(7, arr);
		var _relS = getInputSingle(8, arr);
		var _conS = getInputSingle(9, arr);
		
		var _dim = surface_get_dimension(_surf);
		
		switch(_outt) {
			case 1 : 
				_dim[0] *= _relS[0];
				_dim[1] *= _relS[1];
				break;
				
			case 2 : _dim = _conS; break;
		}
		
		return _dim;
	} 
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _suf = _data[0];
			var _pos = _data[1];
			var _ang = _data[2];
			var _spk = _data[4];
			var _ref = _data[5];
			var _sca = _data[6];
			
			var _outt = _data[7];
			var _relS = _data[8];
			var _conS = _data[9];
			
			var _rsca = _data[10];
			var _trim = _data[13];
			
			inputs[8].setVisible(_outt == 1);
			inputs[9].setVisible(_outt == 2);
		#endregion
			
		var _dim = surface_get_dimension(_outSurf);
		
		surface_set_shader(_outSurf, sh_mirror_polar);
			shader_set_interpolation(_suf);
			shader_set_f( "dimension", _dim );
			shader_set_2( "position",  _pos );
			shader_set_f( "angle",     degtorad(_ang));
			shader_set_f_map( "spokes",_spk, _data[11], inputs[4], _data[12] );
			shader_set_i( "reflecc",   _ref );
			shader_set_2( "scale",     _sca );
			shader_set_i( "rscale",   _rsca );
			shader_set_f( "trim",     _trim );
			
			draw_surface_stretched_safe(_suf, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		return _outSurf;
	}
}