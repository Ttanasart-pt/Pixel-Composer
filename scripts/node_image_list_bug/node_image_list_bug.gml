function Node_Image_List_Bug(_x, _y, _group = undefined) : Node(_x, _y, _group) constructor {
	name = "Bug List";
	update_on_frame = true;
	
	newInput(0, nodeValue_Surface( "Texts", [])).setVisible(true, true);
	newInput(1, nodeValue_Dimension());
	
	////- =Positioning
	newInput(2, nodeValue_Vec2(  "Origin",  [ 200, 500 ] ));
	newInput(5, nodeValue_Float( "Spacing", 8 ));
	newInput(6, nodeValue_Curve( "Ease in", CURVE_DEF_01 ));
	
	////- =Timing
	newInput(3, nodeValue_Float( "Time Per List", 8    ));
	newInput(4, nodeValue_Int(   "Start Frame",   8    ));
	
	newOutput(0, nodeValue_Output("Atlas data", VALUE_TYPE.surface, noone));
	
	b_match_len  = button(function() /*=>*/ { 
		var _surf = getInputData(0);
		var _star = getInputData(4);
		var _tlis = getInputData(3);
		
		TOTAL_FRAMES = _star + array_length(_surf) * _tlis + 30;
	}).setText("Match Animation Length");
	
	temp_surface = [ noone, noone ];
	
	input_display_list = [ 0, 1, 
	    ["Positioning", false], 2, 5, 6, 
	    ["Timing",      false], 4, 3, b_match_len, 
	];
	
	static update = function(frame = CURRENT_FRAME) {
		var _surf = getInputData(0);
		var _dim  = getInputData(1);
		
		var _orig = getInputData(2);
		var _spac = getInputData(5);
		var _ease = getInputData(6);
		
		var _star = getInputData(4);
		var _tlis = getInputData(3);
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		var _amo = array_length(_surf);
		var _xx  = _orig[0];
		var _yy  = _orig[1];
		
		var _afrm  = frame - _star;
		var _index = clamp(floor(_afrm / _tlis), 0, _amo - 1);
		var _aind  = (_afrm - _index * _tlis) / _tlis;
		
		var _ainde = eval_curve_x(_ease, _aind);
		
		surface_set_shader(_outSurf);
			for( var j = _index; j >= 0; j-- ) {
				var _s  = _surf[j];
				
				var _sw = surface_get_width(_s);
				var _sh = surface_get_height(_s);
				
				if(j == _index) {
					draw_set_alpha(_ainde);
					_yy += (1 - _ainde) * _sh;
				}
				
				draw_surface(_s, _xx, _yy + _sh);
				draw_set_alpha(1);
				
				_yy -= _sh + _spac;
			}
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
	}
}

